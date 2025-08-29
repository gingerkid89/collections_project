-- Fix coordinates for key Bonn restaurants and museums

-- Your favorite restaurants
UPDATE places SET latitude = 50.7219, longitude = 7.0847 WHERE name = 'Spacca Napoli';
UPDATE places SET latitude = 50.7156, longitude = 7.1289 WHERE name = 'Via Roma';
UPDATE places SET latitude = 50.7351, longitude = 7.1026 WHERE name = 'Terra Rossa';

-- Tuscolo locations (central Cologne/Bonn area)
UPDATE places SET latitude = 50.9389, longitude = 6.9533 WHERE name = 'Tuscolo Frankenbad';
UPDATE places SET latitude = 50.9364, longitude = 6.9528 WHERE name = 'Tuscolo Münsterblick';

-- Other restaurants
UPDATE places SET latitude = 50.9419, longitude = 6.9583 WHERE name = 'Restaurant Ruland';
UPDATE places SET latitude = 50.7089, longitude = 7.1314 WHERE name = 'L''Osteria Bonn';

-- Key museums
UPDATE places SET latitude = 50.9419, longitude = 6.9589 WHERE name = 'Beethoven-Haus Bonn';
UPDATE places SET latitude = 50.7200, longitude = 7.0847 WHERE name = 'Haus der Geschichte';
UPDATE places SET latitude = 50.7183, longitude = 7.0869 WHERE name = 'Kunstmuseum Bonn';

-- Verify updates
SELECT name, latitude, longitude FROM places WHERE name IN ('Spacca Napoli', 'Via Roma', 'Terra Rossa', 'Beethoven-Haus Bonn') ORDER BY name;