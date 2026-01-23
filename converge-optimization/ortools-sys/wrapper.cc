// C++ implementation of the OR-Tools wrapper
// Focused on CP-SAT and GLOP only

#include "wrapper.h"

#include <memory>
#include <string>
#include <vector>

// OR-Tools headers
#include "ortools/sat/cp_model.h"
#include "ortools/sat/cp_model_solver.h"
#include "ortools/linear_solver/linear_solver.h"

using namespace operations_research;

// ============================================================================
// Internal wrapper structs
// ============================================================================

struct CpModelBuilder {
    sat::CpModelBuilder builder;
    std::vector<sat::IntVar> vars;  // Store actual IntVar objects for later use
};

struct CpSolverResponse {
    sat::CpSolverResponse response;
    sat::CpModelProto model;  // Keep model for variable lookup
};

struct MpSolver {
    std::unique_ptr<operations_research::MPSolver> solver;
    std::vector<MPVariable*> variables;
    std::vector<MPConstraint*> constraints;
};

// ============================================================================
// Helper to convert status
// ============================================================================

static OrtoolsStatus convert_cp_status(sat::CpSolverStatus status) {
    switch (status) {
        case sat::CpSolverStatus::OPTIMAL:
            return ORTOOLS_STATUS_OPTIMAL;
        case sat::CpSolverStatus::FEASIBLE:
            return ORTOOLS_STATUS_FEASIBLE;
        case sat::CpSolverStatus::INFEASIBLE:
            return ORTOOLS_STATUS_INFEASIBLE;
        case sat::CpSolverStatus::MODEL_INVALID:
            return ORTOOLS_STATUS_MODEL_INVALID;
        default:
            return ORTOOLS_STATUS_UNKNOWN;
    }
}

static OrtoolsStatus convert_lp_status(MPSolver::ResultStatus status) {
    switch (status) {
        case MPSolver::OPTIMAL:
            return ORTOOLS_STATUS_OPTIMAL;
        case MPSolver::FEASIBLE:
            return ORTOOLS_STATUS_FEASIBLE;
        case MPSolver::INFEASIBLE:
            return ORTOOLS_STATUS_INFEASIBLE;
        case MPSolver::UNBOUNDED:
            return ORTOOLS_STATUS_UNBOUNDED;
        default:
            return ORTOOLS_STATUS_ERROR;
    }
}

// ============================================================================
// CP-SAT Implementation
// ============================================================================

extern "C" {

CpModelBuilder* cpmodel_new(void) {
    return new CpModelBuilder();
}

void cpmodel_free(CpModelBuilder* model) {
    delete model;
}

int32_t cpmodel_new_int_var(CpModelBuilder* model, int64_t lb, int64_t ub, const char* name) {
    sat::IntVar var = model->builder.NewIntVar(Domain(lb, ub));
    if (name && name[0]) {
        var.WithName(name);
    }
    int32_t idx = static_cast<int32_t>(model->vars.size());
    model->vars.push_back(var);
    return idx;
}

int32_t cpmodel_new_bool_var(CpModelBuilder* model, const char* name) {
    sat::BoolVar bvar = model->builder.NewBoolVar();
    if (name && name[0]) {
        bvar.WithName(name);
    }
    // Store as IntVar (BoolVar is convertible to IntVar)
    int32_t idx = static_cast<int32_t>(model->vars.size());
    model->vars.push_back(static_cast<sat::IntVar>(bvar));
    return idx;
}

// Helper to build LinearExpr from indices
static sat::LinearExpr build_linear_expr(CpModelBuilder* model,
                                         const int32_t* var_indices,
                                         const int64_t* coeffs,
                                         size_t num_vars) {
    sat::LinearExpr expr;
    for (size_t i = 0; i < num_vars; ++i) {
        expr += model->vars[var_indices[i]] * coeffs[i];
    }
    return expr;
}

void cpmodel_add_linear_le(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs) {
    auto expr = build_linear_expr(model, var_indices, coeffs, num_vars);
    model->builder.AddLessOrEqual(expr, rhs);
}

void cpmodel_add_linear_ge(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs) {
    auto expr = build_linear_expr(model, var_indices, coeffs, num_vars);
    model->builder.AddGreaterOrEqual(expr, rhs);
}

void cpmodel_add_linear_eq(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs) {
    auto expr = build_linear_expr(model, var_indices, coeffs, num_vars);
    model->builder.AddEquality(expr, rhs);
}

void cpmodel_add_all_different(CpModelBuilder* model,
                               const int32_t* var_indices,
                               size_t num_vars) {
    std::vector<sat::IntVar> vars;
    vars.reserve(num_vars);
    for (size_t i = 0; i < num_vars; ++i) {
        vars.push_back(model->vars[var_indices[i]]);
    }
    model->builder.AddAllDifferent(vars);
}

void cpmodel_minimize(CpModelBuilder* model,
                      const int32_t* var_indices,
                      const int64_t* coeffs,
                      size_t num_vars) {
    auto expr = build_linear_expr(model, var_indices, coeffs, num_vars);
    model->builder.Minimize(expr);
}

void cpmodel_maximize(CpModelBuilder* model,
                      const int32_t* var_indices,
                      const int64_t* coeffs,
                      size_t num_vars) {
    auto expr = build_linear_expr(model, var_indices, coeffs, num_vars);
    model->builder.Maximize(expr);
}

CpSolverResponse* cpmodel_solve(CpModelBuilder* model, double time_limit_seconds) {
    sat::SatParameters params;
    if (time_limit_seconds > 0) {
        params.set_max_time_in_seconds(time_limit_seconds);
    }

    auto* result = new CpSolverResponse();
    result->model = model->builder.Build();
    result->response = sat::SolveWithParameters(result->model, params);
    return result;
}

OrtoolsStatus cpresponse_status(const CpSolverResponse* response) {
    return convert_cp_status(response->response.status());
}

int64_t cpresponse_objective_value(const CpSolverResponse* response) {
    return static_cast<int64_t>(response->response.objective_value());
}

int64_t cpresponse_value(const CpSolverResponse* response, int32_t var_index) {
    return response->response.solution(var_index);
}

double cpresponse_wall_time(const CpSolverResponse* response) {
    return response->response.wall_time();
}

void cpresponse_free(CpSolverResponse* response) {
    delete response;
}

// ============================================================================
// Linear Solver (GLOP) Implementation
// ============================================================================

MpSolver* mpsolver_new(const char* name, OrtoolsLpSolverType solver_type) {
    MPSolver::OptimizationProblemType problem_type;
    switch (solver_type) {
        case ORTOOLS_LP_GLOP:
            problem_type = MPSolver::GLOP_LINEAR_PROGRAMMING;
            break;
        case ORTOOLS_LP_CLP:
            problem_type = MPSolver::CLP_LINEAR_PROGRAMMING;
            break;
        case ORTOOLS_MIP_CBC:
            problem_type = MPSolver::CBC_MIXED_INTEGER_PROGRAMMING;
            break;
        case ORTOOLS_MIP_SCIP:
            problem_type = MPSolver::SCIP_MIXED_INTEGER_PROGRAMMING;
            break;
        default:
            problem_type = MPSolver::GLOP_LINEAR_PROGRAMMING;
    }

    auto* result = new MpSolver();
    result->solver = std::make_unique<operations_research::MPSolver>(
        name ? name : "solver", problem_type);
    return result;
}

void mpsolver_free(MpSolver* solver) {
    delete solver;
}

int32_t mpsolver_num_var(MpSolver* solver, double lb, double ub, const char* name) {
    auto* var = solver->solver->MakeNumVar(lb, ub, name ? name : "");
    int32_t idx = static_cast<int32_t>(solver->variables.size());
    solver->variables.push_back(var);
    return idx;
}

int32_t mpsolver_int_var(MpSolver* solver, double lb, double ub, const char* name) {
    auto* var = solver->solver->MakeIntVar(lb, ub, name ? name : "");
    int32_t idx = static_cast<int32_t>(solver->variables.size());
    solver->variables.push_back(var);
    return idx;
}

int32_t mpsolver_bool_var(MpSolver* solver, const char* name) {
    auto* var = solver->solver->MakeBoolVar(name ? name : "");
    int32_t idx = static_cast<int32_t>(solver->variables.size());
    solver->variables.push_back(var);
    return idx;
}

int32_t mpsolver_add_constraint(MpSolver* solver, double lb, double ub, const char* name) {
    auto* constraint = solver->solver->MakeRowConstraint(lb, ub, name ? name : "");
    int32_t idx = static_cast<int32_t>(solver->constraints.size());
    solver->constraints.push_back(constraint);
    return idx;
}

void mpsolver_set_constraint_coeff(MpSolver* solver, int32_t constraint_idx, int32_t var_idx, double coeff) {
    solver->constraints[constraint_idx]->SetCoefficient(solver->variables[var_idx], coeff);
}

void mpsolver_set_objective_coeff(MpSolver* solver, int32_t var_idx, double coeff) {
    solver->solver->MutableObjective()->SetCoefficient(solver->variables[var_idx], coeff);
}

void mpsolver_minimize(MpSolver* solver) {
    solver->solver->MutableObjective()->SetMinimization();
}

void mpsolver_maximize(MpSolver* solver) {
    solver->solver->MutableObjective()->SetMaximization();
}

OrtoolsStatus mpsolver_solve(MpSolver* solver) {
    return convert_lp_status(solver->solver->Solve());
}

double mpsolver_objective_value(const MpSolver* solver) {
    return solver->solver->Objective().Value();
}

double mpsolver_var_value(const MpSolver* solver, int32_t var_idx) {
    return solver->variables[var_idx]->solution_value();
}

}  // extern "C"
