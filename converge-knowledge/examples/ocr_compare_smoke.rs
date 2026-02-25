use anyhow::{Result, anyhow};
use converge_knowledge::ingest::{
    AppleVisionOcrBackend, AppleVisionOcrConfig, OcrTextBlock, PhotoIngester, PhotoIngesterConfig,
    ScreenshotIngester, ScreenshotIngesterConfig, TesseractOcrBackend, TesseractOcrConfig,
};
use std::collections::BTreeSet;
use std::env;
use std::path::{Path, PathBuf};

enum Mode {
    Screenshot,
    Photo,
}

struct OcrRunSuccess {
    backend: &'static str,
    version: Option<String>,
    title: String,
    chunks: usize,
    block_count: usize,
    metadata_keys: usize,
    text: String,
    blocks_preview: Vec<OcrTextBlock>,
}

struct OcrRunFailure {
    backend: &'static str,
    version: Option<String>,
    error: String,
}

enum OcrRun {
    Success(OcrRunSuccess),
    Failure(OcrRunFailure),
}

fn usage(program: &str) -> String {
    format!(
        "Usage:\n  {program} <screenshot|photo> <image_path> [apple_langs] [tesseract_langs]\n\nExamples:\n  {program} screenshot ./tmp/shot.png en-US eng\n  {program} photo ./tmp/photo.jpg en-US+de-DE eng+deu\n\nEnv overrides:\n  APPLE_VISION_BIN=/usr/bin/xcrun\n  TESSERACT_BIN=/opt/homebrew/bin/tesseract\n"
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

fn split_langs(raw: Option<&str>) -> Vec<String> {
    raw.unwrap_or_default()
        .split('+')
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .map(ToOwned::to_owned)
        .collect()
}

fn build_apple_config(language_codes: Option<&str>) -> AppleVisionOcrConfig {
    let mut config = AppleVisionOcrConfig::default();
    if let Ok(bin) = env::var("APPLE_VISION_BIN")
        && !bin.trim().is_empty()
    {
        config = config.with_binary_path(bin);
    }

    let langs = split_langs(language_codes);
    if !langs.is_empty() {
        config = config.with_default_languages(langs);
    }
    config
}

fn build_tesseract_config(language_codes: Option<&str>) -> TesseractOcrConfig {
    let mut config = TesseractOcrConfig::default();
    if let Ok(bin) = env::var("TESSERACT_BIN")
        && !bin.trim().is_empty()
    {
        config = config.with_binary_path(bin);
    }

    let langs = split_langs(language_codes);
    if !langs.is_empty() {
        config = config.with_default_languages(langs);
    }
    config
}

fn first_line(text: &str) -> String {
    text.lines().next().unwrap_or(text).to_string()
}

fn text_preview(text: &str, max: usize) -> String {
    if text.len() <= max {
        text.to_string()
    } else {
        format!("{}...", &text[..max])
    }
}

fn normalized_lines(text: &str) -> Vec<String> {
    text.lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(ToOwned::to_owned)
        .collect()
}

fn print_block_summary(idx: usize, block: &OcrTextBlock) {
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

fn print_run(run: &OcrRun) {
    match run {
        OcrRun::Success(ok) => {
            println!("{}: ok", ok.backend);
            if let Some(version) = &ok.version {
                println!("  version: {}", first_line(version));
            }
            println!("  title: {}", ok.title);
            println!("  chunks: {}", ok.chunks);
            println!("  ocr blocks: {}", ok.block_count);
            println!("  metadata keys: {}", ok.metadata_keys);
            println!("  text chars: {}", ok.text.len());
            println!("  text preview: {}", text_preview(&ok.text, 280));
            if !ok.blocks_preview.is_empty() {
                println!("  top blocks:");
                for (idx, block) in ok.blocks_preview.iter().enumerate() {
                    print!("    ");
                    print_block_summary(idx, block);
                }
            }
        }
        OcrRun::Failure(err) => {
            println!("{}: failed", err.backend);
            if let Some(version) = &err.version {
                println!("  version: {}", first_line(version));
            }
            println!("  error: {}", err.error);
        }
    }
}

fn print_comparison(apple: &OcrRunSuccess, tesseract: &OcrRunSuccess) {
    let apple_lines = normalized_lines(&apple.text);
    let tess_lines = normalized_lines(&tesseract.text);
    let apple_set: BTreeSet<String> = apple_lines.iter().cloned().collect();
    let tess_set: BTreeSet<String> = tess_lines.iter().cloned().collect();

    let intersection: BTreeSet<String> = apple_set.intersection(&tess_set).cloned().collect();
    let apple_only: Vec<String> = apple_set.difference(&tess_set).cloned().collect();
    let tess_only: Vec<String> = tess_set.difference(&apple_set).cloned().collect();
    let union_count = apple_set.union(&tess_set).count();
    let jaccard = if union_count == 0 {
        1.0
    } else {
        intersection.len() as f32 / union_count as f32
    };

    println!("\n== Comparison ==");
    println!("Exact text match: {}", apple.text == tesseract.text);
    println!("Apple lines: {}", apple_lines.len());
    println!("Tesseract lines: {}", tess_lines.len());
    println!("Shared unique lines: {}", intersection.len());
    println!("Apple-only unique lines: {}", apple_only.len());
    println!("Tesseract-only unique lines: {}", tess_only.len());
    println!("Line Jaccard similarity: {:.3}", jaccard);

    if !apple_only.is_empty() {
        println!("\nApple-only line samples:");
        for line in apple_only.iter().take(5) {
            println!("  - {}", line);
        }
    }
    if !tess_only.is_empty() {
        println!("\nTesseract-only line samples:");
        for line in tess_only.iter().take(5) {
            println!("  - {}", line);
        }
    }
}

async fn run_apple(mode: &Mode, path: &Path, language_codes: Option<&str>) -> OcrRun {
    let config = build_apple_config(language_codes);
    let backend = AppleVisionOcrBackend::with_config(config.clone());
    let version = backend.version().await.ok();

    match mode {
        Mode::Screenshot => {
            let ingester = ScreenshotIngester::with_apple_vision_and_config(
                config,
                ScreenshotIngesterConfig::default(),
            );
            match ingester.ingest_file(path).await {
                Ok(doc) => {
                    let title = doc.title.clone();
                    let chunks = doc.chunks.len();
                    let block_count = doc.ocr.blocks.len();
                    let metadata_keys = doc.metadata.len();
                    let text = doc.indexing_text();
                    let blocks_preview = doc.ocr.blocks.into_iter().take(8).collect();

                    OcrRun::Success(OcrRunSuccess {
                        backend: "apple_vision",
                        version,
                        title,
                        chunks,
                        block_count,
                        metadata_keys,
                        text,
                        blocks_preview,
                    })
                }
                Err(err) => OcrRun::Failure(OcrRunFailure {
                    backend: "apple_vision",
                    version,
                    error: err.to_string(),
                }),
            }
        }
        Mode::Photo => {
            let ingester =
                PhotoIngester::with_apple_vision_and_config(config, PhotoIngesterConfig::default());
            match ingester.ingest_file(path).await {
                Ok(doc) => {
                    let title = doc.title.clone();
                    let chunks = doc.chunks.len();
                    let block_count = doc.ocr.blocks.len();
                    let metadata_keys = doc.metadata.len();
                    let text = doc.indexing_text();
                    let blocks_preview = doc.ocr.blocks.into_iter().take(8).collect();

                    OcrRun::Success(OcrRunSuccess {
                        backend: "apple_vision",
                        version,
                        title,
                        chunks,
                        block_count,
                        metadata_keys,
                        text,
                        blocks_preview,
                    })
                }
                Err(err) => OcrRun::Failure(OcrRunFailure {
                    backend: "apple_vision",
                    version,
                    error: err.to_string(),
                }),
            }
        }
    }
}

async fn run_tesseract(mode: &Mode, path: &Path, language_codes: Option<&str>) -> OcrRun {
    let config = build_tesseract_config(language_codes);
    let backend = TesseractOcrBackend::with_config(config.clone());
    let version = backend.version().await.ok();

    match mode {
        Mode::Screenshot => {
            let ingester = ScreenshotIngester::with_tesseract_and_config(
                config,
                ScreenshotIngesterConfig::default(),
            );
            match ingester.ingest_file(path).await {
                Ok(doc) => {
                    let title = doc.title.clone();
                    let chunks = doc.chunks.len();
                    let block_count = doc.ocr.blocks.len();
                    let metadata_keys = doc.metadata.len();
                    let text = doc.indexing_text();
                    let blocks_preview = doc.ocr.blocks.into_iter().take(8).collect();

                    OcrRun::Success(OcrRunSuccess {
                        backend: "tesseract",
                        version,
                        title,
                        chunks,
                        block_count,
                        metadata_keys,
                        text,
                        blocks_preview,
                    })
                }
                Err(err) => OcrRun::Failure(OcrRunFailure {
                    backend: "tesseract",
                    version,
                    error: err.to_string(),
                }),
            }
        }
        Mode::Photo => {
            let ingester =
                PhotoIngester::with_tesseract_and_config(config, PhotoIngesterConfig::default());
            match ingester.ingest_file(path).await {
                Ok(doc) => {
                    let title = doc.title.clone();
                    let chunks = doc.chunks.len();
                    let block_count = doc.ocr.blocks.len();
                    let metadata_keys = doc.metadata.len();
                    let text = doc.indexing_text();
                    let blocks_preview = doc.ocr.blocks.into_iter().take(8).collect();

                    OcrRun::Success(OcrRunSuccess {
                        backend: "tesseract",
                        version,
                        title,
                        chunks,
                        block_count,
                        metadata_keys,
                        text,
                        blocks_preview,
                    })
                }
                Err(err) => OcrRun::Failure(OcrRunFailure {
                    backend: "tesseract",
                    version,
                    error: err.to_string(),
                }),
            }
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = env::args().collect::<Vec<_>>();
    let program = args
        .first()
        .map(String::as_str)
        .unwrap_or("ocr_compare_smoke");

    if args.len() < 3 || args.iter().any(|arg| arg == "--help" || arg == "-h") {
        print!("{}", usage(program));
        return Ok(());
    }

    let mode = parse_mode(&args[1]).map_err(|msg| {
        let full = format!("{msg}\n\n{}", usage(program));
        std::io::Error::new(std::io::ErrorKind::InvalidInput, full)
    })?;
    let path = PathBuf::from(&args[2]);
    let apple_langs = args.get(3).map(String::as_str);
    let tesseract_langs = args.get(4).map(String::as_str);

    if !Path::new(&path).exists() {
        return Err(anyhow!("image path not found: {}", path.display()));
    }

    println!("Mode: {}", args[1]);
    println!("Path: {}", path.display());
    println!(
        "Apple langs: {}",
        apple_langs.unwrap_or("(default from AppleVisionOcrConfig)")
    );
    println!(
        "Tesseract langs: {}",
        tesseract_langs.unwrap_or("(default from TesseractOcrConfig)")
    );
    println!();

    let (apple_run, tesseract_run) = tokio::join!(
        run_apple(&mode, &path, apple_langs),
        run_tesseract(&mode, &path, tesseract_langs)
    );

    println!("== Apple Vision ==");
    print_run(&apple_run);
    println!();
    println!("== Tesseract ==");
    print_run(&tesseract_run);

    if let (OcrRun::Success(apple_ok), OcrRun::Success(tess_ok)) = (&apple_run, &tesseract_run) {
        print_comparison(apple_ok, tess_ok);
    } else {
        println!("\nComparison summary skipped because at least one backend failed.");
    }

    Ok(())
}
