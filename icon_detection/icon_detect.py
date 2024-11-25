import torch
from transformers import AutoImageProcessor, AutoModelForObjectDetection
from PIL import Image
import numpy as np

def load_model():
    """Load the OmniParser icon detection model"""
    processor = AutoImageProcessor.from_pretrained("microsoft/OmniParser", subfolder="icon_detect")
    model = AutoModelForObjectDetection.from_pretrained("microsoft/OmniParser", subfolder="icon_detect")
    return processor, model

def detect_icons(image_path, processor, model, confidence_threshold=0.5):
    """Detect icons in the given image"""
    # Load and preprocess image
    image = Image.open(image_path)
    inputs = processor(images=image, return_tensors="pt")

    # Run inference
    with torch.no_grad():
        outputs = model(**inputs)

    # Post-process results
    target_sizes = torch.tensor([image.size[::-1]])
    results = processor.post_process_object_detection(
        outputs, threshold=confidence_threshold, target_sizes=target_sizes
    )[0]

    detections = []
    for score, label, box in zip(results["scores"], results["labels"], results["boxes"]):
        box = [round(i) for i in box.tolist()]
        detections.append({
            'box': box,
            'score': score.item(),
            'label': model.config.id2label[label.item()]
        })

    return detections

if __name__ == "__main__":
    # Example usage
    processor, model = load_model()
    image_path = "example_screenshot.png"  # Replace with your image path
    detections = detect_icons(image_path, processor, model)

    print("Detected icons:")
    for det in detections:
        print(f"Label: {det['label']}, Score: {det['score']:.2f}, Box: {det['box']}")
