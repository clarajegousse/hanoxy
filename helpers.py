# for testing
#file = '/users/home/cat3/projects/hanoxy/data/samples/infos/samples.txt'
#sample = 'TARA_078'

def sample2runs(sample, file):
	with open(file, 'r') as info:
		runs = []
		for line in info:
			if sample == line.split("\t")[0]:
				r1s = line.strip('\n').split("\t")[1].split(',')
				r2s = line.strip('\n').split("\t")[2].split(',')
				for r in r1s:
					runs.append(r.split('_')[0].strip('"'))
	return runs

def run2url(wildcards):
	run = wildcards.run
	num = wildcards.num
	base = 'ftp://ftp.sra.ebi.ac.uk/vol1/fastq/'
	if len(run) == 10:
		url = base + run[0:6] + '/00' + run[-1] + '/' + run + '/' + run + '_' + num + '.fastq.gz'
	else:
		url = base + run[0:6] + '/' + run + "/" + run + '_' + num + '.fastq.gz'
	return url

def ui_config(sample, runs, raw_data_dir):
	filename = 'sample_%s.txt' %sample
	with open(filename, 'w') as f:
		header = 'sample' + '\t' + 'r1' + '\t' + 'r2' + '\n'
		paths_to_r1 = []
		paths_to_r2 = []
		#print(header)
		f.write(header)
		for r in runs:
			paths_to_r1.append(raw_data_dir + '/' + r + '_1.fastq.gz')
			paths_to_r2.append(raw_data_dir + '/' + r + '_2.fastq.gz')
		sample_info = sample + '\t' + ','.join(paths_to_r1) + '\t' + ','.join(paths_to_r2)
		#print(sample_info)
		f.write(sample_info)
	return filename
