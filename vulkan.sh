# vulkan drivers
Vulkan=$(xrandr --listproviders)
if [[ "$Vulkan" == *"NVIDIA"* ]]; then
	export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
else
	export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
fi
