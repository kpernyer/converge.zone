//! OpenAI embedding provider.
//!
//! Uses the OpenAI API to generate high-quality text embeddings.
//! Supports text-embedding-3-small, text-embedding-3-large, and text-embedding-ada-002.

use super::EmbeddingProvider;
use crate::error::{Error, Result};
use serde::{Deserialize, Serialize};

/// OpenAI embedding provider.
pub struct OpenAIEmbedding {
    api_key: String,
    model: String,
    dimensions: usize,
}

impl OpenAIEmbedding {
    /// Create a new OpenAI embedding provider.
    ///
    /// # Arguments
    /// * `api_key` - OpenAI API key
    /// * `model` - Optional model name (defaults to text-embedding-3-small)
    pub fn new(api_key: impl Into<String>, model: Option<String>) -> Self {
        let model = model.unwrap_or_else(|| "text-embedding-3-small".to_string());
        let dimensions = match model.as_str() {
            "text-embedding-3-large" => 3072,
            "text-embedding-3-small" => 1536,
            "text-embedding-ada-002" => 1536,
            _ => 1536,
        };

        Self {
            api_key: api_key.into(),
            model,
            dimensions,
        }
    }

    /// Set custom dimensions (for text-embedding-3-* models).
    pub fn with_dimensions(mut self, dimensions: usize) -> Self {
        self.dimensions = dimensions;
        self
    }
}

#[derive(Serialize)]
struct EmbeddingRequest {
    model: String,
    input: Vec<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    dimensions: Option<usize>,
}

#[derive(Deserialize)]
struct EmbeddingResponse {
    data: Vec<EmbeddingData>,
    model: String,
    usage: Usage,
}

#[derive(Deserialize)]
struct EmbeddingData {
    embedding: Vec<f32>,
    index: usize,
}

#[derive(Deserialize)]
struct Usage {
    prompt_tokens: usize,
    total_tokens: usize,
}

#[derive(Deserialize)]
struct ErrorResponse {
    error: ApiError,
}

#[derive(Deserialize)]
struct ApiError {
    message: String,
    #[serde(rename = "type")]
    error_type: String,
}

#[async_trait::async_trait]
impl EmbeddingProvider for OpenAIEmbedding {
    async fn embed(&self, text: &str) -> Result<Vec<f32>> {
        let embeddings = self.embed_batch(&[text]).await?;
        embeddings
            .into_iter()
            .next()
            .ok_or_else(|| Error::embedding("No embedding returned"))
    }

    async fn embed_batch(&self, texts: &[&str]) -> Result<Vec<Vec<f32>>> {
        if texts.is_empty() {
            return Ok(Vec::new());
        }

        let request = EmbeddingRequest {
            model: self.model.clone(),
            input: texts.iter().map(|s| s.to_string()).collect(),
            dimensions: if self.model.starts_with("text-embedding-3") {
                Some(self.dimensions)
            } else {
                None
            },
        };

        let client = reqwest::Client::new();
        let response = client
            .post("https://api.openai.com/v1/embeddings")
            .header("Authorization", format!("Bearer {}", self.api_key))
            .header("Content-Type", "application/json")
            .json(&request)
            .send()
            .await
            .map_err(|e| Error::embedding(format!("Request failed: {}", e)))?;

        let status = response.status();
        let body = response
            .text()
            .await
            .map_err(|e| Error::embedding(format!("Failed to read response: {}", e)))?;

        if !status.is_success() {
            let error: ErrorResponse = serde_json::from_str(&body)
                .map_err(|_| Error::embedding(format!("API error: {}", body)))?;
            return Err(Error::embedding(format!(
                "OpenAI API error: {}",
                error.error.message
            )));
        }

        let response: EmbeddingResponse = serde_json::from_str(&body)
            .map_err(|e| Error::embedding(format!("Failed to parse response: {}", e)))?;

        // Sort by index to maintain input order
        let mut data = response.data;
        data.sort_by_key(|d| d.index);

        Ok(data.into_iter().map(|d| d.embedding).collect())
    }

    fn dimensions(&self) -> usize {
        self.dimensions
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_openai_dimensions() {
        let provider = OpenAIEmbedding::new("test-key", None);
        assert_eq!(provider.dimensions(), 1536);

        let provider = OpenAIEmbedding::new("test-key", Some("text-embedding-3-large".to_string()));
        assert_eq!(provider.dimensions(), 3072);
    }

    #[test]
    fn test_custom_dimensions() {
        let provider = OpenAIEmbedding::new("test-key", Some("text-embedding-3-small".to_string()))
            .with_dimensions(512);
        assert_eq!(provider.dimensions(), 512);
    }
}
