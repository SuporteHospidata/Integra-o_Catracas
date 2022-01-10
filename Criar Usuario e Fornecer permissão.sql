CREATE USER teletex WITH PASSWORD 'teletex@123';
GRANT USAGE ON SCHEMA sigh TO teletex;
GRANT SELECT ON sigh.v_controle_acesso TO teletex;