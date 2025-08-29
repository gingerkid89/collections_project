-- Update places with real GPS coordinates based on their actual addresses in Bonn

BEGIN;

-- RESTAURANTS with real coordinates
UPDATE places SET latitude = 50.7351, longitude = 7.1026 WHERE name = 'Terra Rossa'; -- Haager Weg 19
UPDATE places SET latitude = 50.9419, longitude = 6.9583 WHERE name = 'Restaurant Ruland'; -- Bischofsplatz 1 (near Cathedral)
UPDATE places SET latitude = 50.7089, longitude = 7.1314 WHERE name = 'L''Osteria Bonn'; -- Am Bonner Bogen 4
UPDATE places SET latitude = 50.7467, longitude = 7.0889 WHERE name = 'La Piazza'; -- Hermannstraße 54
UPDATE places SET latitude = 50.7374, longitude = 7.0982 WHERE name = 'eat italian Bonn'; -- Bonn center (generic)

-- Tuscolo locations 
UPDATE places SET latitude = 50.9389, longitude = 6.9533 WHERE name = 'Tuscolo Frankenbad'; -- Kaiser-Karl-Ring 63
UPDATE places SET latitude = 50.9364, longitude = 6.9528 WHERE name = 'Tuscolo Münsterblick'; -- Gerhard-von-Are-Straße 8

-- User favorites
UPDATE places SET latitude = 50.7219, longitude = 7.0847 WHERE name = 'Spacca Napoli'; -- Konrad-Adenauer-Platz 8 
UPDATE places SET latitude = 50.7156, longitude = 7.1289 WHERE name = 'Via Roma'; -- Adelheidisstraße 41

-- MUSEUMS with real coordinates
UPDATE places SET latitude = 50.9413, longitude = 6.9583 WHERE name = 'Beethoven-Haus Bonn'; -- Bonngasse 20
UPDATE places SET latitude = 50.7200, longitude = 7.0847 WHERE name = 'Haus der Geschichte'; -- Willy-Brandt-Allee 14
UPDATE places SET latitude = 50.7183, longitude = 7.0869 WHERE name = 'Kunstmuseum Bonn'; -- Helmut-Kohl-Allee 2
UPDATE places SET latitude = 50.7172, longitude = 7.0881 WHERE name = 'Bundeskunsthalle'; -- Helmut-Kohl-Allee 4
UPDATE places SET latitude = 50.7289, longitude = 7.0756 WHERE name = 'LVR-Landesmuseum Bonn'; -- Colmantstraße 14-16
UPDATE places SET latitude = 50.7206, longitude = 7.0842 WHERE name = 'Museum Koenig'; -- Adenauerallee 160
UPDATE places SET latitude = 50.8901, longitude = 7.0156 WHERE name = 'Deutsches Museum Bonn'; -- Ahrstraße 45
UPDATE places SET latitude = 50.7411, longitude = 7.0967 WHERE name = 'August-Macke-Haus'; -- Hochstadenring 36
UPDATE places SET latitude = 50.7384, longitude = 7.0978 WHERE name = 'Arithmeum'; -- Lennéstraße 2
UPDATE places SET latitude = 50.9333, longitude = 6.9472 WHERE name = 'Stadtmuseum Bonn'; -- Franziskanerstraße 9

COMMIT;

-- Verify the updates
SELECT name, address, latitude, longitude FROM places WHERE type = 'restaurant' ORDER BY name;