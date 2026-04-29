use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use kk_core::osm::import_osm_pbf;

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.iter().any(|arg| arg == "-h" || arg == "--help") {
        print_help();
        return Ok(());
    }

    let input = arg_value(&args, "--input")
        .or_else(|| args.first().map(String::as_str))
        .ok_or("missing input .osm.pbf path")?;
    let output = arg_value(&args, "--output")
        .or_else(|| args.get(1).map(String::as_str))
        .ok_or("missing output .kkosm path")?;

    let input = PathBuf::from(input);
    let output = PathBuf::from(output);

    eprintln!("reading {}", input.display());
    let (pack, report) = import_osm_pbf(&input)?;

    eprintln!("writing {}", output.display());
    pack.save_bincode(&output)?;

    println!("source: {}", report.source);
    println!("highway ways: {}", report.highway_ways);
    println!("road segments: {}", report.road_segments);
    println!("total length: {:.1} km", report.total_length_m / 1000.0);
    println!("skipped missing nodes: {}", report.skipped_missing_nodes);
    println!("skipped degenerate segments: {}", report.skipped_degenerate_segments);

    Ok(())
}

fn arg_value<'a>(args: &'a [String], flag: &str) -> Option<&'a str> {
    args.windows(2)
        .find(|pair| pair[0] == flag)
        .map(|pair| pair[1].as_str())
}

fn print_help() {
    println!(
        "kk_osm_pack\n\nUsage:\n  cargo run -p kk_core --bin kk_osm_pack -- --input region.osm.pbf --output region.kkosm\n  cargo run -p kk_core --bin kk_osm_pack -- region.osm.pbf region.kkosm"
    );
}
