def truncate(x, w, b):            # keep top b bits of a w-bit value
    return x >> (w - b)

def clip_scale(x, lo, hi, b):     # clip to [lo, hi], rescale linearly to b bits
    x = np.clip(x, lo, hi)
    return ((x - lo) * ((1 << b) - 1) // (hi - lo)).astype(int)