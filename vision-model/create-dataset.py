from clearml import Dataset

from pathlib import Path

def main():
  dataset = Dataset.create(
    dataset_name='Pothole Data',
    dataset_project='YOLOv8',
    dataset_version='1.0',
    description='Pothole image dataset for training YOLOv8'
  )

  dataset.add_files(
    Path('pothole_dataset_v8'),
    recursive=True
  )

  dataset.upload()
  dataset.finalize()

if __name__ == '__main__':
  main()