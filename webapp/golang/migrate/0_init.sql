USE isuconp;
CREATE TABLE IF NOT EXISTS schema_migrations (
  id int unsigned NOT NULL AUTO_INCREMENT,
  version int unsigned NOT NULL,
  PRIMARY KEY (id)
);
INSERT INTO schema_migrations (version) SELECT (0) WHERE NOT EXISTS (SELECT * FROM schema_migrations);
