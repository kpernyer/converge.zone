use anyhow::{Result, anyhow};
use converge_knowledge::ingest::{
    AppleVisionOcrBackend, AppleVisionOcrConfig, PhotoIngester, PhotoIngesterConfig,
    ScreenshotIngester, ScreenshotIngesterConfig,
};
use std::env;
use std::path::{Path, PathBuf};

enum Mode {
    Screenshot,
    Photo,
}

fn usage(program: &str) -> String {
    format!(
        "Usage:\n  {program} <screenshot|photo> <image_path> [language_codes]\n\nExamples:\n  {program} screenshot ./tmp/shot.png en-US\n  {program} photo ./tmp/photo.jpg en-US+de-DE\n\nOptions via env:\n  APPLE_VISION_BIN=/usr/bin/xcrun\n"
    )
}

fn parse_mode(value: &str) -> Result<Mode, String> {
    match value {
        "screenshot" => Ok(Mode::Screenshot),
        "photo" => Ok(Mode::Photo),
        other => Err(format!(
            "unsupported mode '{other}' (expected screenshot|photo)"
        )),
    }
}

fn build_apple_vision_config(language_codes: Option<&str>) -> AppleVisionOcrConfig {
    let mut config = AppleVisionOcrConfig::default();

    if let Ok(bin) = env::var("APPLE_VISION_BIN") {
        if !bin.trim().is_empty() {
            config = config.with_binary_path(bin);
        }
    }

    if let Some(langs) = language_codes {
        let parsed = langs
            .split('+')
            .map(str::trim)
            .filter(|s| !s.is_empty())
            .map(ToOwned::to_owned)
            .collect::<Vec<_>>();
        if !parsed.is_empty() {
            config = config.with_default_languages(parsed);
        }
    }

    config
}

fn print_block_summary(idx: usize, block: &converge_knowledge::ingest::OcrTextBlock) {
    let conf = block
        .confidence
        .map(|c| format!("{c:.2}"))
        .unwrap_or_else(|| "-".to_string());
    let bbox = block
        .bbox
        .map(|b| format!("{:.3},{:.3},{:.3},{:.3}", b.x, b.y, b.width, b.height))
        .unwrap_or_else(|| "-".to_string());
    println!(
        "  [{idx}] kind={:?} conf={} bbox={} text={}",
        block.kind, conf, bbox, block.text
    );
}

fn print_preview(text: &str) {
    const MAX: usize = 400;
    if text.len() <= MAX {
        println!("{text}");
    } else {
        println!("{}...", &text[..MAX]);
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = env::args().collect::<Vec<_>>();
    let program = args
        .first()
        .map(String::as_str)
        .unwrap_or("apple_vision_ocr_smoke");

    if args.len() < 3 || args.iter().any(|arg| arg == "--help" || arg == "-h") {
        print!("{}", usage(program));
        return Ok(());
    }

    let mode = parse_mode(&args[1]).map_err(|msg| {
        let full = format!("{msg}\n\n{}", usage(program));
        std::io::Error::new(std::io::ErrorKind::InvalidInput, full)
    })?;
    let path = PathBuf::from(&args[2]);
    let language_codes = args.get(3).map(String::as_str);

    if !Path::new(&path).exists() {
        return Err(anyhow!("image path not found: {}", path.display()));
    }

    let apple_config = build_apple_vision_config(language_codes);
    let backend = AppleVisionOcrBackend::with_config(apple_config.clone());
    match backend.version().await {
        Ok(version) => {
            let first_line = version.lines().next().unwrap_or(&version);
            eprintln!("Using Apple Vision runner: {first_line}");
        }
        Err(err) => {
            eprintln!("Apple Vision runner version check failed: {err}");
            return Err(anyhow!(err.to_string()));
        }
    }

    match mode {
        Mode::Screenshot => {
            let ingester = ScreenshotIngester::with_apple_vision_and_config(
                apple_config,
                ScreenshotIngesterConfig::default(),
            );
            let doc = ingester.ingest_file(&path).await?;
            println!("Mode: screenshot");
            println!("Backend: apple_vision");
            println!("Title: {}", doc.title);
            println!("Path: {}", doc.path.display());
            println!("Chunks: {}", doc.chunks.len());
            println!("OCR blocks: {}", doc.ocr.blocks.len());
            println!("Metadata keys: {}", doc.metadata.len());
            println!("\nText preview:");
            print_preview(&doc.indexing_text());
            if !doc.ocr.blocks.is_empty() {
                println!("\nTop OCR blocks:");
                for (idx, block) in doc.ocr.blocks.iter().take(8).enumerate() {
                    print_block_summary(idx, block);
                }
            }
        }
        Mode::Photo => {
            let ingester = PhotoIngester::with_apple_vision_and_config(
                apple_config,
                PhotoIngesterConfig::default(),
            );
            let doc = ingester.ingest_file(&path).await?;
            println!("Mode: photo");
            println!("Backend: apple_vision");
            println!("Title: {}", doc.title);
            println!("Path: {}", doc.path.display());
            println!("Chunks: {}", doc.chunks.len());
            println!("OCR blocks: {}", doc.ocr.blocks.len());
            println!("Metadata keys: {}", doc.metadata.len());
            println!("\nText preview:");
            print_preview(&doc.indexing_text());
            if !doc.ocr.blocks.is_empty() {
                println!("\nTop OCR blocks:");
                for (idx, block) in doc.ocr.blocks.iter().take(8).enumerate() {
                    print_block_summary(idx, block);
                }
            }
        }
    }

    Ok(())
}
