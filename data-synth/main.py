import cv2
import os
import random

def load_images_from_folder(folder):
    images = []
    for filename in os.listdir(folder):
        img = cv2.imread(os.path.join(folder, filename))
        if img is not None:
            images.append(img)
    return images

def random_scaling(image, scale_range=(0.5, 1.5)):
    scale_factor = random.uniform(*scale_range)
    new_size = (int(image.shape[1] * scale_factor), int(image.shape[0] * scale_factor))
    return cv2.resize(image, new_size)

def random_rotation(image, angle_range=(-45, 45)):
    angle = random.uniform(*angle_range)
    center = (image.shape[1] // 2, image.shape[0] // 2)
    rotation_matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    return cv2.warpAffine(image, rotation_matrix, (image.shape[1], image.shape[0]))

def superimpose_images(background, foreground):
    # Random position for the foreground image
    bg_h, bg_w = background.shape[:2]
    fg_h, fg_w = foreground.shape[:2]
    max_x = bg_w - fg_w
    max_y = bg_h - fg_h
    x_offset = random.randint(0, max_x)
    y_offset = random.randint(0, max_y)

    # Create an alpha mask for blending
    alpha_fg = foreground[:, :, 3] / 255.0
    alpha_bg = 1.0 - alpha_fg

    for c in range(0, 3):
        background[y_offset:y_offset+fg_h, x_offset:x_offset+fg_w, c] = \
            (alpha_fg * foreground[:, :, c] + alpha_bg * background[y_offset:y_offset+fg_h, x_offset:x_offset+fg_w, c])
    return background

# Load images
background_images = load_images_from_folder('input/bg')
foreground_images = load_images_from_folder('input/fg')

# Generate synthetic images
synthetic_images = []
for bg in background_images:
    for fg in foreground_images:
        fg_scaled = random_scaling(fg)
        fg_rotated = random_rotation(fg_scaled)
        fg_rgba = cv2.cvtColor(fg_rotated, cv2.COLOR_BGR2BGRA)
        synthetic_image = superimpose_images(bg.copy(), fg_rgba)
        synthetic_images.append(synthetic_image)

# Save synthetic images
output_folder = 'path/to/output'
os.makedirs(output_folder, exist_ok=True)
for i, img in enumerate(synthetic_images):
    cv2.imwrite(os.path.join(output_folder, f'synthetic_{i}.png'), img)