
.PHONY: noop download-checkpoints-cedar download-tensorboard-cedar download-results-cedar upload-code-cedar upload-code-mila

noop:
	echo "preventing default action"

download-checkpoints-cedar:
	rsync --info=progress2 -urltv --delete \
		-e ssh cc-cedar:~/scratch/ecoroar/checkpoints/ ./checkpoints

download-tensorboard-cedar:
	rsync --info=progress2 -urltv --delete \
		-e ssh cc-cedar:~/scratch/ecoroar/tensorboard/ ./tensorboard

download-results-cedar:
	rsync --info=progress2 -urltv --delete \
		-e ssh cc-cedar:~/scratch/ecoroar/results/ ./results

upload-code-cedar:
	rsync --info=progress2 -urltv --delete \
		--filter=':- .gitignore' --exclude='.git/' \
		-e ssh ./ cc-cedar:~/workspace/economical-roar

upload-code-mila:
	rsync --info=progress2 -urltv --delete \
		--filter=':- .gitignore' --exclude='.git/' \
		-e ssh ./ mila:~/workspace/economical-roar
