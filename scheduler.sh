if [ -z "$1" ]
then
    sbatch -p normal -t 92:00:00 -J snake \
    --wrap="snakemake --cluster-config cluster.yaml --cluster 'sbatch -t {cluster.time} -o {cluster.output} -e {cluster.error} --mail-type {cluster.email_type} --mail-user {cluster.email} -p {cluster.queue} ' -j 10 --latency-wait 60"
elif [ $1 = 'unlock' ]
then
    sbatch -J unlock \
        -o snake-unlock.log \
        --wrap="snakemake --unlock" \
        --partition="mimir"
elif [ $1 = "dryrun" ]
then
    sbatch -J dryrun \
    -o snake-dryrun.log \
    --wrap="snakemake -n" \
    --partition="mimir"
elif [ $1 = "dag" ]
then
    sbatch -J dag \
    -o snake-dag.log \
    --wrap="snakemake --dag > dag.dot" \
    --partition="mimir"
fi

snakemake --cluster 'sbatch -t 24:00:00 -p mimir --mail-type ALL --mail-user cat3@hi.is' -j 10 --latency-wait 60
