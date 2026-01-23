// C wrapper header for OR-Tools FFI
// Focused on CP-SAT and GLOP only

#ifndef ORTOOLS_WRAPPER_H_
#define ORTOOLS_WRAPPER_H_

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// Common Types
// ============================================================================

/// Solve status codes
typedef enum {
    ORTOOLS_STATUS_UNKNOWN = 0,
    ORTOOLS_STATUS_OPTIMAL = 1,
    ORTOOLS_STATUS_FEASIBLE = 2,
    ORTOOLS_STATUS_INFEASIBLE = 3,
    ORTOOLS_STATUS_UNBOUNDED = 4,
    ORTOOLS_STATUS_MODEL_INVALID = 5,
    ORTOOLS_STATUS_ERROR = 6,
} OrtoolsStatus;

// ============================================================================
// CP-SAT Solver
// ============================================================================

/// Opaque handle to CP-SAT model builder
typedef struct CpModelBuilder CpModelBuilder;

/// Opaque handle to CP-SAT solver response
typedef struct CpSolverResponse CpSolverResponse;

/// Create a new CP-SAT model builder
CpModelBuilder* cpmodel_new(void);

/// Free a CP-SAT model builder
void cpmodel_free(CpModelBuilder* model);

/// Add an integer variable with domain [lb, ub], returns variable index
int32_t cpmodel_new_int_var(CpModelBuilder* model, int64_t lb, int64_t ub, const char* name);

/// Add a boolean variable, returns variable index
int32_t cpmodel_new_bool_var(CpModelBuilder* model, const char* name);

/// Add constraint: sum(coeffs[i] * vars[i]) <= rhs
void cpmodel_add_linear_le(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs);

/// Add constraint: sum(coeffs[i] * vars[i]) >= rhs
void cpmodel_add_linear_ge(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs);

/// Add constraint: sum(coeffs[i] * vars[i]) == rhs
void cpmodel_add_linear_eq(CpModelBuilder* model,
                           const int32_t* var_indices,
                           const int64_t* coeffs,
                           size_t num_vars,
                           int64_t rhs);

/// Add all-different constraint
void cpmodel_add_all_different(CpModelBuilder* model,
                               const int32_t* var_indices,
                               size_t num_vars);

/// Set objective: minimize sum(coeffs[i] * vars[i])
void cpmodel_minimize(CpModelBuilder* model,
                      const int32_t* var_indices,
                      const int64_t* coeffs,
                      size_t num_vars);

/// Set objective: maximize sum(coeffs[i] * vars[i])
void cpmodel_maximize(CpModelBuilder* model,
                      const int32_t* var_indices,
                      const int64_t* coeffs,
                      size_t num_vars);

/// Solve the model with optional time limit (0 = no limit)
CpSolverResponse* cpmodel_solve(CpModelBuilder* model, double time_limit_seconds);

/// Get solve status
OrtoolsStatus cpresponse_status(const CpSolverResponse* response);

/// Get objective value
int64_t cpresponse_objective_value(const CpSolverResponse* response);

/// Get value of a variable in the solution
int64_t cpresponse_value(const CpSolverResponse* response, int32_t var_index);

/// Get wall time in seconds
double cpresponse_wall_time(const CpSolverResponse* response);

/// Free solver response
void cpresponse_free(CpSolverResponse* response);

// ============================================================================
// Linear Solver (GLOP)
// ============================================================================

/// Linear solver types
typedef enum {
    ORTOOLS_LP_GLOP = 0,       // Google's linear programming solver
    ORTOOLS_LP_CLP = 1,        // COIN-OR Linear Programming
    ORTOOLS_MIP_CBC = 2,       // COIN-OR Branch and Cut
    ORTOOLS_MIP_SCIP = 3,      // SCIP mixed-integer programming
} OrtoolsLpSolverType;

/// Opaque handle to linear solver
typedef struct MpSolver MpSolver;

/// Create a new linear solver
MpSolver* mpsolver_new(const char* name, OrtoolsLpSolverType solver_type);

/// Free a linear solver
void mpsolver_free(MpSolver* solver);

/// Create a continuous variable, returns variable index
int32_t mpsolver_num_var(MpSolver* solver, double lb, double ub, const char* name);

/// Create an integer variable, returns variable index
int32_t mpsolver_int_var(MpSolver* solver, double lb, double ub, const char* name);

/// Create a boolean variable, returns variable index
int32_t mpsolver_bool_var(MpSolver* solver, const char* name);

/// Add a constraint: lb <= sum(coeffs[i] * vars[i]) <= ub
/// Returns constraint index
int32_t mpsolver_add_constraint(MpSolver* solver, double lb, double ub, const char* name);

/// Set coefficient in constraint
void mpsolver_set_constraint_coeff(MpSolver* solver, int32_t constraint_idx, int32_t var_idx, double coeff);

/// Set objective coefficient
void mpsolver_set_objective_coeff(MpSolver* solver, int32_t var_idx, double coeff);

/// Set to minimize
void mpsolver_minimize(MpSolver* solver);

/// Set to maximize
void mpsolver_maximize(MpSolver* solver);

/// Solve the problem
OrtoolsStatus mpsolver_solve(MpSolver* solver);

/// Get objective value
double mpsolver_objective_value(const MpSolver* solver);

/// Get variable value
double mpsolver_var_value(const MpSolver* solver, int32_t var_idx);

#ifdef __cplusplus
}
#endif

#endif  // ORTOOLS_WRAPPER_H_
