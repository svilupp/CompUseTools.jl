import torch
from ultralytics import YOLO
import cv2
import numpy as np
import json
import supervision as sv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from PIL import Image
import os
import time
from safetensors.torch import load_file

def setup_chromium():
    """Set up headless Chrome browser for screenshots"""
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--remote-debugging-port=9222')
    return webdriver.Chrome(options=chrome_options)

def capture_screenshot(url, output_path, driver):
    """Capture a screenshot of the webpage"""
    driver.get(url)
    driver.save_screenshot(output_path)
    return output_path

def load_model():
    """Load the OmniParser icon detection model"""
    model_path = os.path.join(os.path.dirname(__file__), "model", "model.safetensors")
    yaml_path = os.path.join(os.path.dirname(__file__), "model", "model.yaml")

    # Load model using YOLO with custom weights
    model = YOLO(yaml_path)
    model.model.load_state_dict(load_file(model_path))
    model.task = 'detect'
    return model

def detect_icons(image_path, model, conf_threshold=0.1):  # Lower confidence threshold
    """Detect icons in the given image and return their bounding boxes"""
    results = model(image_path)[0]
    detections = []

    for box, score, class_id in zip(results.boxes.xyxy, results.boxes.conf, results.boxes.cls):
        if score >= conf_threshold:
            x1, y1, x2, y2 = box.cpu().numpy()
            detections.append({
                'bbox': [int(x1), int(y1), int(x2), int(y2)],
                'confidence': float(score),
                'class_id': 0,  # Single class model
                'class_name': 'icon'  # Fixed class name
            })

    return detections

def save_detections(detections, output_path):
    """Save detection results to a JSON file"""
    with open(output_path, 'w') as f:
        json.dump(detections, f, indent=2)

def visualize_detections(image_path, detections, output_path):
    """Draw bounding boxes on the image and save it"""
    image = cv2.imread(image_path)

    if not detections:
        cv2.imwrite(output_path, image)
        return

    boxes = np.array([d['bbox'] for d in detections])
    confidences = np.array([d['confidence'] for d in detections])
    class_ids = np.array([d['class_id'] for d in detections])

    sv_detections = sv.Detections(
        xyxy=boxes,
        confidence=confidences,
        class_id=class_ids
    )

    box_annotator = sv.BoxAnnotator()
    frame = box_annotator.annotate(scene=image, detections=sv_detections)
    cv2.imwrite(output_path, frame)

if __name__ == "__main__":
    # Example usage
    driver = setup_chromium()
    try:
        # Capture screenshot of a simpler webpage
        screenshot_path = "screenshot.png"
        url = "https://google.com"
        print(f"Capturing screenshot from {url}...")
        capture_screenshot(url, screenshot_path, driver)
        time.sleep(5)  # Increased wait time for page load

        if not os.path.exists(screenshot_path):
            print(f"Error: Screenshot not saved at {screenshot_path}")
            exit(1)

        print(f"Screenshot saved successfully ({os.path.getsize(screenshot_path)} bytes)")

        # Run icon detection
        print("Loading model...")
        model = load_model()
        print("Running detection...")
        detections = detect_icons(screenshot_path, model)
        save_detections(detections, "detections.json")
        visualize_detections(screenshot_path, detections, "annotated_screenshot.png")

        print(f"\nFound {len(detections)} potential icons")
        for d in detections:
            print(f"Class: {d['class_name']}, Confidence: {d['confidence']:.2f}, Box: {d['bbox']}")
    finally:
        driver.quit()
