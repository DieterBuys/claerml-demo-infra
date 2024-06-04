from clearml import Task, TaskTypes
from ultralytics import YOLO

task = Task.init(
    project_name='YOLOv8',
    task_name='Evaluate YOLOv8 Pothole Detection',
    task_type=TaskTypes.testing
)

model = YOLO('runs/detect/yolov8s/weights/best.pt')

results = model.val(
  data='pothole_v8.yaml',
  imgsz=1280,
  batch=8,
  name='YOLOv8 Small Eval'
)
