STATUS=""
ITER=0
while [ "$STATUS" != "RUNNING" ] ; do
    ITER=$((ITER+1))
    if [ "$ITER" -gt 120 ]; then exit 1; fi
    STATUS=$(iofog-agent status | cut -f2 -d: | head -n 1 | tr -d '[:space:]')
    [ "$STATUS" != "RUNNING" ] && sleep 1
done