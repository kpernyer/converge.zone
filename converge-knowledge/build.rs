//! Build script for generating gRPC code from protobuf definitions.

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile protobuf definitions
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/grpc")
        .compile_protos(&["proto/knowledge.proto"], &["proto"])?;

    // Rerun if proto files change
    println!("cargo:rerun-if-changed=proto/knowledge.proto");

    Ok(())
}
