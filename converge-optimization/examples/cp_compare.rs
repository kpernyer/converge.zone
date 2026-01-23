//! Compare FFI CP-SAT vs Native Varisat-based CP
//!
//! Run with: cargo run --features sat,ffi --example cp_compare

fn main() {
    #[cfg(all(feature = "sat", feature = "ffi"))]
    {
        println!("=== CP Solver Comparison ===\n");

        // Test 1: Simple satisfaction (all different)
        println!("Test 1: All-Different Constraint (n=4)");
        println!("-----------------------------------------");

        // Native
        {
            use converge_optimization::cp::{CpModel, CpStatus};
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let vars: Vec<_> = (0..4)
                .map(|i| model.new_int_var(1, 4, &format!("x{}", i)))
                .collect();
            model.add_all_different(&vars);

            let solution = model.solve();
            let elapsed = start.elapsed();

            println!(
                "Native:  status={:?}, time={:.3}ms",
                solution.status,
                elapsed.as_secs_f64() * 1000.0
            );
            if solution.status.is_success() {
                let vals: Vec<i64> = vars.iter().map(|v| solution.value(*v)).collect();
                println!("         values={:?}", vals);
            }
        }

        // FFI
        {
            use ortools_sys::safe::*;
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let vars: Vec<_> = (0..4)
                .map(|i| model.new_int_var(1, 4, &format!("x{}", i)))
                .collect();
            model.add_all_different(&vars);

            let solution = model.solve(60.0);
            let elapsed = start.elapsed();

            println!(
                "FFI:     status={:?}, time={:.3}ms",
                solution.status(),
                elapsed.as_secs_f64() * 1000.0
            );
            if solution.status().is_success() {
                let vals: Vec<i64> = vars.iter().map(|v| solution.value(*v)).collect();
                println!("         values={:?}", vals);
            }
        }

        // Test 2: Linear optimization
        println!("\nTest 2: Linear Optimization (minimize x, x+y=10)");
        println!("-------------------------------------------------");

        // Native
        {
            use converge_optimization::cp::{CpModel, CpStatus};
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let x = model.new_int_var(0, 10, "x");
            let y = model.new_int_var(0, 10, "y");
            model.add_linear_eq(&[x, y], &[1, 1], 10);
            model.minimize(&[x], &[1]);

            let solution = model.solve();
            let elapsed = start.elapsed();

            println!(
                "Native:  status={:?}, time={:.3}ms",
                solution.status,
                elapsed.as_secs_f64() * 1000.0
            );
            if solution.status.is_success() {
                println!(
                    "         x={}, y={}, obj={}",
                    solution.value(x),
                    solution.value(y),
                    solution.objective_value.unwrap_or(0)
                );
            }
        }

        // FFI
        {
            use ortools_sys::safe::*;
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let x = model.new_int_var(0, 10, "x");
            let y = model.new_int_var(0, 10, "y");
            model.add_linear_eq(&[x, y], &[1, 1], 10);
            model.minimize(&[x], &[1]);

            let solution = model.solve(60.0);
            let elapsed = start.elapsed();

            println!(
                "FFI:     status={:?}, time={:.3}ms",
                solution.status(),
                elapsed.as_secs_f64() * 1000.0
            );
            if solution.status().is_success() {
                println!(
                    "         x={}, y={}, obj={}",
                    solution.value(x),
                    solution.value(y),
                    solution.objective_value()
                );
            }
        }

        // Test 3: Larger all-different
        println!("\nTest 3: All-Different (n=8)");
        println!("---------------------------");

        // Native
        {
            use converge_optimization::cp::{CpModel, CpStatus};
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let vars: Vec<_> = (0..8)
                .map(|i| model.new_int_var(1, 8, &format!("x{}", i)))
                .collect();
            model.add_all_different(&vars);

            let solution = model.solve();
            let elapsed = start.elapsed();

            println!(
                "Native:  status={:?}, time={:.3}ms",
                solution.status,
                elapsed.as_secs_f64() * 1000.0
            );
        }

        // FFI
        {
            use ortools_sys::safe::*;
            let start = std::time::Instant::now();

            let mut model = CpModel::new();
            let vars: Vec<_> = (0..8)
                .map(|i| model.new_int_var(1, 8, &format!("x{}", i)))
                .collect();
            model.add_all_different(&vars);

            let solution = model.solve(60.0);
            let elapsed = start.elapsed();

            println!(
                "FFI:     status={:?}, time={:.3}ms",
                solution.status(),
                elapsed.as_secs_f64() * 1000.0
            );
        }

        println!("\n=== Summary ===");
        println!("The FFI approach uses Google OR-Tools CP-SAT which is highly optimized.");
        println!("The native approach uses a simple SAT encoding with Varisat.");
        println!("For complex problems, FFI will typically be faster due to OR-Tools' propagators.");
    }

    #[cfg(not(all(feature = "sat", feature = "ffi")))]
    {
        eprintln!("This example requires both 'sat' and 'ffi' features");
        eprintln!("Run with: cargo run --features sat,ffi --example cp_compare");
    }
}
