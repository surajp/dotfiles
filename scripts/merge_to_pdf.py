#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pillow>=10.0.0",
#     "img2pdf>=0.5.0",
#     "pypdf>=4.0.0",
#     "pyobjc-framework-Vision>=9.0; sys_platform == 'darwin'",
# ]
# ///
"""
merge_to_pdf.py

CLI tool to merge all images and PDFs in a specified directory into a single PDF.
- Uses macOS Vision OCR to automatically detect and correct image orientation (right-side up).
- Fits images neatly onto standard Letter pages without distortion or clipping.
- Preserves native PDFs and appends them in order.
- Generates outline bookmarks for each file.
"""

import argparse
import io
import os
import re
import sys
from pathlib import Path
from PIL import Image, ImageOps
import img2pdf
import pypdf

# Common receipt / document terms used to score reading orientation
KEYWORDS = {
    "total", "subtotal", "tax", "cash", "date", "amount", "balance",
    "due", "payment", "thank", "store", "receipt", "order", "time",
    "sale", "item", "items", "usd", "tip", "visa", "mastercard",
    "amex", "card", "welcome", "guest", "charge", "charges", "credit",
    "phone", "plaza", "hotel", "ave", "street", "st", "rd", "dr"
}

# PIL counter-clockwise angles corresponding to CGImagePropertyOrientation
# 1 (.up): 0°
# 3 (.down): 180°
# 6 (.right): 90° CW -> PIL rotate 270° CCW
# 8 (.left): 270° CW -> PIL rotate 90° CCW
ORIENTATION_TO_PIL_ROTATION = {
    1: 0,
    3: 180,
    6: 270,
    8: 90,
}

SUPPORTED_IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff", ".tif"}
SUPPORTED_EXTS = SUPPORTED_IMAGE_EXTS | {".pdf"}


def detect_image_orientation(file_path: Path) -> int:
    """
    On macOS, uses the Vision framework to determine the upright orientation.
    Returns the CGImagePropertyOrientation (1, 3, 6, or 8).
    Fallback to 1 (unrotated) on non-macOS or if detection fails.
    """
    if sys.platform != "darwin":
        return 1

    try:
        import Vision
        from Foundation import NSURL

        url = NSURL.fileURLWithPath_(str(file_path.resolve()))
        scores = {}
        for ori in [1, 6, 3, 8]:
            req = Vision.VNRecognizeTextRequest.alloc().init()
            req.setRecognitionLevel_(1)  # accurate
            handler = Vision.VNImageRequestHandler.alloc().initWithURL_orientation_options_(url, ori, None)
            handler.performRequests_error_([req], None)
            results = req.results() or []
            
            horiz_count = sum(1 for r in results if r.boundingBox().size.width > r.boundingBox().size.height)
            words = []
            for r in results:
                text = r.topCandidates_(1)[0].string().lower()
                words.extend(re.findall(r"[a-z]+", text))
            matched_keywords = sum(1 for w in words if w in KEYWORDS)
            
            scores[ori] = (matched_keywords, horiz_count, len(results))
        
        best_ori = max(scores.keys(), key=lambda k: (scores[k][0], scores[k][1]))
        return best_ori
    except Exception as exc:
        print(f"  [warn] Vision orientation detection skipped for {file_path.name}: {exc}")
        return 1


def prepare_image_for_pdf(file_path: Path, auto_rotate: bool) -> bytes:
    """
    Opens image, normalizes EXIF orientation, applies detected upright rotation,
    converts alpha to RGB, and returns JPEG bytes.
    """
    with Image.open(file_path) as img:
        img = ImageOps.exif_transpose(img) or img
        
        if auto_rotate:
            best_ori = detect_image_orientation(file_path)
            rot_deg = ORIENTATION_TO_PIL_ROTATION.get(best_ori, 0)
            if rot_deg != 0:
                print(f"  -> auto-rotating {rot_deg}° (detected orientation: {best_ori})")
                img = img.rotate(rot_deg, expand=True)

        if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
            bg = Image.new("RGB", img.size, (255, 255, 255))
            if img.mode == "P":
                img = img.convert("RGBA")
            bg.paste(img, mask=img.split()[3] if img.mode == "RGBA" else None)
            img = bg
        elif img.mode != "RGB":
            img = img.convert("RGB")

        out_io = io.BytesIO()
        img.save(out_io, format="JPEG", quality=95)
        return out_io.getvalue()


def merge_folder(
    folder_path: Path,
    output_path: Path,
    auto_rotate: bool = True,
    page_size: str = "letter"
):
    folder = folder_path.resolve()
    if not folder.is_dir():
        raise ValueError(f"Target path is not a directory: {folder}")

    candidates = sorted([
        f for f in folder.iterdir()
        if not f.name.startswith(".")
        and f.resolve() != output_path.resolve()
        and f.suffix.lower() in SUPPORTED_EXTS
    ])

    if not candidates:
        print(f"No supported images or PDFs found in: {folder}")
        return

    print(f"Found {len(candidates)} file(s) in {folder.name}/ to merge:")
    for f in candidates:
        print(f"  - {f.name}")

    writer = pypdf.PdfWriter()

    if page_size == "letter":
        page_dim = (img2pdf.in_to_pt(8.5), img2pdf.in_to_pt(11))
        layout_fun = img2pdf.get_layout_fun(pagesize=page_dim, fit=img2pdf.FitMode.into, auto_orient=True)
    elif page_size == "a4":
        page_dim = (img2pdf.in_to_pt(8.27), img2pdf.in_to_pt(11.69))
        layout_fun = img2pdf.get_layout_fun(pagesize=page_dim, fit=img2pdf.FitMode.into, auto_orient=True)
    else:
        layout_fun = img2pdf.get_layout_fun(fit=img2pdf.FitMode.into, auto_orient=True)

    page_cursor = 0
    for f in candidates:
        print(f"\nProcessing {f.name}...")
        ext = f.suffix.lower()
        if ext == ".pdf":
            reader = pypdf.PdfReader(str(f))
            bookmark_added = False
            for page in reader.pages:
                writer.add_page(page)
                if not bookmark_added:
                    writer.add_outline_item(f.name, page_cursor)
                    bookmark_added = True
                page_cursor += 1
        elif ext in SUPPORTED_IMAGE_EXTS:
            img_bytes = prepare_image_for_pdf(f, auto_rotate=auto_rotate)
            pdf_bytes = img2pdf.convert(img_bytes, layout_fun=layout_fun)
            reader = pypdf.PdfReader(io.BytesIO(pdf_bytes))
            for page in reader.pages:
                writer.add_page(page)
                writer.add_outline_item(f.name, page_cursor)
                page_cursor += 1

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as out_f:
        writer.write(out_f)

    print(f"\n✓ Successfully created: {output_path} ({page_cursor} pages)")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Merge all images and PDFs in a folder into a single PDF with auto-orientation."
    )
    parser.add_argument(
        "folder",
        nargs="?",
        default=".",
        help="Path to folder containing receipts/documents (default: current directory)"
    )
    parser.add_argument(
        "-o", "--output",
        default=None,
        help="Output PDF path or filename (default: <folder>/all_receipts.pdf)"
    )
    parser.add_argument(
        "--no-rotate",
        action="store_true",
        help="Disable automatic upright OCR orientation detection"
    )
    parser.add_argument(
        "--page-size",
        choices=["letter", "a4", "original"],
        default="letter",
        help="Target page size for images (default: letter)"
    )
    return parser.parse_args()


def main():
    args = parse_args()
    folder = Path(args.folder).resolve()

    if args.output:
        out = Path(args.output)
        if not out.is_absolute():
            out = folder / out
    else:
        out = folder / "all_receipts.pdf"

    merge_folder(
        folder_path=folder,
        output_path=out,
        auto_rotate=not args.no_rotate,
        page_size=args.page_size
    )


if __name__ == "__main__":
    main()
