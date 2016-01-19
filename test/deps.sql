-- You will need to delete this if you do not want to use pgTap!
CREATE SCHEMA IF NOT EXISTS tap;
CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA tap;

-- Add any test dependency statements here
CREATE EXTENSION IF NOT EXISTS plpythonu;
CREATE EXTENSION IF NOT EXISTS lambda;
CREATE EXTENSION PandaPost;
