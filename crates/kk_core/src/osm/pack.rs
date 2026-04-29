use std::fs::File;
use std::io::{BufReader, BufWriter};
use std::path::Path;

use thiserror::Error;

use crate::osm::model::OsmPack;

#[derive(Debug, Error)]
pub enum PackIoError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("bincode error: {0}")]
    Bincode(#[from] bincode::Error),
}

impl OsmPack {
    pub fn save_bincode(&self, path: impl AsRef<Path>) -> Result<(), PackIoError> {
        let file = File::create(path)?;
        let writer = BufWriter::new(file);
        bincode::serialize_into(writer, self)?;
        Ok(())
    }

    pub fn load_bincode(path: impl AsRef<Path>) -> Result<Self, PackIoError> {
        let file = File::open(path)?;
        let reader = BufReader::new(file);
        Ok(bincode::deserialize_from(reader)?)
    }
}
