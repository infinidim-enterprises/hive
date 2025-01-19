while [[ $# -gt 0 ]]; do
  case $1 in
  --db-user)
    DB_USER="$2"
    shift
    ;;
  --db-host)
    DB_HOST="$2"
    shift
    ;;
  --db-port)
    DB_PORT="$2"
    shift
    ;;
  --db-password)
    DB_PASSWORD="$2"
    shift
    ;;
  *)
    echo "Unknown parameter: $1"
    exit 1
    ;;
  esac
  shift
done

DB_NAME="postgres"
DB_USER="${DB_USER:-postgres}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_PASSWORD="${DB_PASSWORD:-}"

if [[ -z $DB_PASSWORD ]]; then
  CONNECTION_STRING="postgresql://${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
else
  CONNECTION_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

QUERY="SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'init_done');"

until nc -d -z "${DB_HOST}" "${DB_PORT}"; do
  echo "Waiting for sql server. Retrying in 5 seconds..."
  sleep 5
done

until psql "${CONNECTION_STRING}" -c "${QUERY}" -t | grep -q "t"; do
  echo "Table 'init_done' not found. Retrying in 5 seconds..."
  sleep 5
done

echo "Table 'init_done' found!"
exit 0
