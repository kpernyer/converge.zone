//! OCR contracts for screenshots and photos.
//!
//! This module defines shared request/response types and backend traits used by
//! Phase 2 image ingestion specialists. Backends (Apple Vision, Tesseract, mock)
//! can implement the trait without changing ingestion orchestration logic.

use crate::Result;
use crate::error::Error;
use crate::ingest::SourceProvenance;
use async_trait::async_trait;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

/// Supported OCR engine families.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OcrEngine {
    /// Apple Vision OCR on macOS.
    AppleVision,
    /// Tesseract OCR.
    Tesseract,
    /// Test/mock backend.
    Mock,
    /// Any external/custom provider.
    External,
}

/// The source image type being processed.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OcrTargetKind {
    /// A screen capture where UI chrome may be present.
    Screenshot,
    /// A photo captured by a camera.
    Photo,
    /// Generic image input where no source-specific assumptions apply.
    GenericImage,
}

/// Bounding box for OCR blocks in normalized coordinates (0.0..=1.0).
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct BoundingBox {
    /// Left X coordinate.
    pub x: f32,
    /// Top Y coordinate.
    pub y: f32,
    /// Width.
    pub width: f32,
    /// Height.
    pub height: f32,
}

impl BoundingBox {
    /// Returns `true` when the box is non-negative and inside normalized bounds.
    pub fn is_normalized(&self) -> bool {
        self.x >= 0.0
            && self.y >= 0.0
            && self.width >= 0.0
            && self.height >= 0.0
            && self.x <= 1.0
            && self.y <= 1.0
            && self.width <= 1.0
            && self.height <= 1.0
            && self.x + self.width <= 1.0
            && self.y + self.height <= 1.0
    }
}

/// OCR block classification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OcrBlockKind {
    /// Paragraph-level text block.
    Paragraph,
    /// Line-level text block.
    Line,
    /// Word/token-level OCR block.
    Word,
    /// UI chrome text (menus, buttons, labels) in screenshots.
    UiChrome,
    /// Unclassified OCR block.
    Unknown,
}

/// A single OCR-detected text block.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OcrTextBlock {
    /// The recognized text.
    pub text: String,
    /// Confidence from 0.0 to 1.0 when provided by the backend.
    pub confidence: Option<f32>,
    /// Normalized bounding box when provided by the backend.
    pub bbox: Option<BoundingBox>,
    /// Classification for this block.
    pub kind: OcrBlockKind,
}

impl OcrTextBlock {
    /// Create a basic line block with no confidence or bounding box.
    pub fn line(text: impl Into<String>) -> Self {
        Self {
            text: text.into(),
            confidence: None,
            bbox: None,
            kind: OcrBlockKind::Line,
        }
    }
}

/// Request passed to OCR backends.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImageOcrRequest {
    /// Path to the source image file.
    pub path: PathBuf,
    /// High-level target kind for backend tuning.
    pub target_kind: OcrTargetKind,
    /// Shared provenance metadata for this image.
    pub provenance: SourceProvenance,
    /// Language hints (e.g., `en`, `de`) to improve OCR.
    pub language_hints: Vec<String>,
    /// Optional minimum confidence filter hint.
    pub min_confidence: Option<f32>,
    /// Source-specific request metadata.
    pub metadata: HashMap<String, String>,
}

impl ImageOcrRequest {
    /// Create a new OCR request.
    pub fn new(
        path: impl Into<PathBuf>,
        target_kind: OcrTargetKind,
        provenance: SourceProvenance,
    ) -> Self {
        Self {
            path: path.into(),
            target_kind,
            provenance,
            language_hints: Vec::new(),
            min_confidence: None,
            metadata: HashMap::new(),
        }
    }

    /// Add a language hint.
    pub fn with_language_hint(mut self, language: impl Into<String>) -> Self {
        self.language_hints.push(language.into());
        self
    }

    /// Set a minimum confidence hint.
    pub fn with_min_confidence(mut self, min_confidence: f32) -> Self {
        self.min_confidence = Some(min_confidence);
        self
    }
}

/// OCR extraction result.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OcrDocument {
    /// OCR backend used to produce this result.
    pub engine: OcrEngine,
    /// The source target kind.
    pub target_kind: OcrTargetKind,
    /// Full-text result if the backend produced one directly.
    pub full_text: String,
    /// Structured OCR blocks.
    pub blocks: Vec<OcrTextBlock>,
    /// Extraction timestamp.
    pub extracted_at: DateTime<Utc>,
    /// Shared provenance for the source image.
    pub provenance: SourceProvenance,
}

impl OcrDocument {
    /// Create an empty OCR document for incremental population.
    pub fn new(
        engine: OcrEngine,
        target_kind: OcrTargetKind,
        provenance: SourceProvenance,
    ) -> Self {
        Self {
            engine,
            target_kind,
            full_text: String::new(),
            blocks: Vec::new(),
            extracted_at: Utc::now(),
            provenance,
        }
    }

    /// Returns the best available text for indexing.
    ///
    /// Uses `full_text` when present, otherwise concatenates non-empty blocks.
    pub fn effective_text(&self) -> String {
        let trimmed = self.full_text.trim();
        if !trimmed.is_empty() {
            return trimmed.to_string();
        }

        self.blocks
            .iter()
            .map(|block| block.text.trim())
            .filter(|text| !text.is_empty())
            .collect::<Vec<_>>()
            .join("\n")
    }

    /// Returns text from blocks whose confidence meets the threshold.
    pub fn filtered_text(&self, min_confidence: f32) -> String {
        self.blocks
            .iter()
            .filter(|block| block.confidence.unwrap_or(1.0) >= min_confidence)
            .map(|block| block.text.trim())
            .filter(|text| !text.is_empty())
            .collect::<Vec<_>>()
            .join("\n")
    }
}

/// OCR backend contract used by screenshot/photo ingestion pipelines.
#[async_trait]
pub trait OcrBackend: Send + Sync {
    /// The engine identifier for this backend.
    fn engine(&self) -> OcrEngine;

    /// Extract OCR text and block metadata from an image.
    async fn extract(&self, request: &ImageOcrRequest) -> Result<OcrDocument>;
}

/// Fixture-driven OCR backend for tests and local scaffolding.
///
/// This backend returns pre-registered OCR results keyed by exact file path,
/// file name, or file stem (in that order). It is intended for ingestion
/// pipeline development when native OCR runtimes are unavailable.
#[derive(Debug, Clone)]
pub struct FixtureOcrBackend {
    engine: OcrEngine,
    documents: HashMap<String, OcrDocument>,
    default_document: Option<OcrDocument>,
}

impl FixtureOcrBackend {
    /// Create an empty fixture backend using the mock engine label.
    pub fn new() -> Self {
        Self {
            engine: OcrEngine::Mock,
            documents: HashMap::new(),
            default_document: None,
        }
    }

    /// Create an empty fixture backend with a custom engine label.
    pub fn with_engine(engine: OcrEngine) -> Self {
        Self {
            engine,
            documents: HashMap::new(),
            default_document: None,
        }
    }

    /// Register a fixture document for a given path-like lookup key.
    ///
    /// The key can be:
    /// - exact path string
    /// - file name (e.g., `Screenshot.png`)
    /// - file stem (e.g., `Screenshot`)
    pub fn with_document(mut self, key: impl Into<String>, document: OcrDocument) -> Self {
        self.documents.insert(key.into(), document);
        self
    }

    /// Register a default fixture returned when no key-specific fixture exists.
    pub fn with_default_document(mut self, document: OcrDocument) -> Self {
        self.default_document = Some(document);
        self
    }

    fn lookup(&self, path: &std::path::Path) -> Option<&OcrDocument> {
        let exact = path.to_string_lossy();
        if let Some(doc) = self.documents.get(exact.as_ref()) {
            return Some(doc);
        }

        if let Some(file_name) = path.file_name().and_then(|name| name.to_str())
            && let Some(doc) = self.documents.get(file_name)
        {
            return Some(doc);
        }

        if let Some(file_stem) = path.file_stem().and_then(|stem| stem.to_str())
            && let Some(doc) = self.documents.get(file_stem)
        {
            return Some(doc);
        }

        self.default_document.as_ref()
    }
}

impl Default for FixtureOcrBackend {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl OcrBackend for FixtureOcrBackend {
    fn engine(&self) -> OcrEngine {
        self.engine.clone()
    }

    async fn extract(&self, request: &ImageOcrRequest) -> Result<OcrDocument> {
        let Some(template) = self.lookup(&request.path) else {
            return Err(Error::ingest(format!(
                "no OCR fixture registered for path '{}'",
                request.path.display()
            )));
        };

        let mut doc = template.clone();
        doc.engine = self.engine();
        doc.target_kind = request.target_kind;
        doc.provenance = request.provenance.clone();
        doc.extracted_at = Utc::now();
        Ok(doc)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ingest::{SourceKind, SourceProvenance};

    #[test]
    fn effective_text_falls_back_to_blocks() {
        let provenance = SourceProvenance::new(SourceKind::Screenshot, "file:///shot.png");
        let mut doc = OcrDocument::new(OcrEngine::Mock, OcrTargetKind::Screenshot, provenance);
        doc.blocks.push(OcrTextBlock::line("First line"));
        doc.blocks.push(OcrTextBlock::line("Second line"));

        assert_eq!(doc.effective_text(), "First line\nSecond line");
    }

    #[test]
    fn filtered_text_respects_confidence() {
        let provenance = SourceProvenance::new(SourceKind::Photo, "file:///photo.jpg");
        let mut doc = OcrDocument::new(OcrEngine::Mock, OcrTargetKind::Photo, provenance);
        doc.blocks.push(OcrTextBlock {
            text: "keep".into(),
            confidence: Some(0.95),
            bbox: None,
            kind: OcrBlockKind::Word,
        });
        doc.blocks.push(OcrTextBlock {
            text: "drop".into(),
            confidence: Some(0.20),
            bbox: None,
            kind: OcrBlockKind::Word,
        });

        assert_eq!(doc.filtered_text(0.5), "keep");
    }

    #[test]
    fn bounding_box_validation_checks_normalized_range() {
        let valid = BoundingBox {
            x: 0.1,
            y: 0.2,
            width: 0.3,
            height: 0.4,
        };
        let invalid = BoundingBox {
            x: 0.8,
            y: 0.9,
            width: 0.4,
            height: 0.2,
        };

        assert!(valid.is_normalized());
        assert!(!invalid.is_normalized());
    }

    #[tokio::test]
    async fn fixture_backend_uses_filename_lookup_and_overrides_provenance() {
        let fixture_provenance = SourceProvenance::new(SourceKind::Screenshot, "fixture://shot");
        let mut fixture_doc = OcrDocument::new(
            OcrEngine::Mock,
            OcrTargetKind::Screenshot,
            fixture_provenance,
        );
        fixture_doc.full_text = "fixture text".into();

        let backend = FixtureOcrBackend::new().with_document("test-shot.png", fixture_doc);

        let request_provenance =
            SourceProvenance::new(SourceKind::Screenshot, "file:///tmp/test-shot.png")
                .with_origin_id("shot-123");
        let request = ImageOcrRequest::new(
            "/tmp/test-shot.png",
            OcrTargetKind::Screenshot,
            request_provenance.clone(),
        );

        let response = backend.extract(&request).await.unwrap();
        assert_eq!(response.full_text, "fixture text");
        assert_eq!(
            response.provenance.source_uri,
            request_provenance.source_uri
        );
        assert_eq!(response.provenance.origin_id, request_provenance.origin_id);
    }
}
