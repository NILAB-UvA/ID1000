import numpy as np
import imageio
import tqdm

filename = 'ID1000_XVIDAVI_169.avi'
vid = imageio.get_reader(filename, 'ffmpeg')
#md = vid.get_meta_data()
#fps = int(md['fps'])
#duration = int(md['duration'])
#x, y = md['source_size']

#arr = np.zeros((duration * fps, int(x), int(y), 3), dtype=np.uint8)
#for i, image in tqdm(enumerate(vid.iter_data())):
#    arr[i, :, :, :] = image

