# app/services/document_parser.py

import logging
import io
import docx
import PyPDF2
from fastapi import UploadFile, HTTPException

logger = logging.getLogger(__name__)

async def parse_document(file: UploadFile) -> str:
    """
    Parses the content of an uploaded file (PDF or DOCX) and returns the extracted text.
    """
    file_extension = file.filename.split(".")[-1].lower()
    allowed_extensions = ["pdf", "docx"]

    if file_extension not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type. Allowed types: {', '.join(allowed_extensions)}"
        )

    file_content = await file.read()
    text_content = ""

    try:
        if file_extension == "pdf":
            pdf_file = io.BytesIO(file_content)
            reader = PyPDF2.PdfReader(pdf_file)
            for page in reader.pages:
                text_content += page.extract_text() or ""
        
        elif file_extension == "docx":
            doc = docx.Document(io.BytesIO(file_content))
            for para in doc.paragraphs:
                text_content += para.text + "\n"

        if not text_content.strip():
            raise ValueError("Could not extract readable text from the document.")

        logger.info(f"Successfully extracted {len(text_content)} characters from {file.filename}.")
        return text_content

    except Exception as e:
        logger.error(f"Error during text extraction from {file.filename}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error extracting text from document: {e}")

