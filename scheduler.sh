if [ -z "$1" ]
then
    sbatch -J snake \
    -o snake.log \
    --wrap="snakemake --cluster-config cluster.yaml --cluster 'sbatch -t {cluster.time} -c {cluster.cpus} -o {cluster.output} -e {cluster.error} --mail-type {cluster.email_type} --mail-user {cluster.email}' -j 10 --latency-wait 60"
elif [ $1 = 'unlock' ]
then
    sbatch -J unlock \
        -o snake.log \
        --wrap="snakemake --unlock" \
        --partition="normal"
elif [ $1 = "dryrun" ]
then
    sbatch -J dryrun \
    -o snake.log \
    --wrap="snakemake -n" \
    --partition="normal"
elif [ $1 = "dag" ]
then
    sbatch -J dag \
    -o snake.log \
    --wrap="snakemake --dag > dag.dot" \
    --partition="normal"
fi
