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
