
L="js python"
A="publish subscribe"
ARG="Hi"
W="str:s"
R="Hi 0 1.2 True"

for l in $L; do
    for arg in $ARG; do
        for a in $A; do
            for w in $W; do
                for r in $R; do
                    TODO="node generator.js lang=$l endpoint=basicReg action=$a want='[\"$w\"]' returns='[\"$r\"]' args='[\"$arg\"]'"
                    #echo $TODO
                    eval $TODO
                    echo "------------------------------------------------------------------------------------------------------------------"
                done
            done
        done
    done
done
