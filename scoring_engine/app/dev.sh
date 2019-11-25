npm run build
go build -o scoring-engine .
#./scoring-engine -config test-fixtures/localhost_service_registry.hcl
./scoring-engine -config ../template/service_registry.hcl