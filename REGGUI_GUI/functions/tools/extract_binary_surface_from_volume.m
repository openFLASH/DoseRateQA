function surface_binary_mask = extract_binary_surface_from_volume(mask)

surface_binary_mask = imerode(single(mask>=0.5),ones(3,3,3));
surface_binary_mask = mask - surface_binary_mask;
