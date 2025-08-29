-- Sample data for testing the Collections App database

-- Insert test user
INSERT INTO users (email, password_hash, display_name) VALUES 
('user@web.com', '$2b$10$example_hash_here', 'Test User');

-- Get the user ID for reference
DO $$
DECLARE
    test_user_id UUID;
    restaurant_id UUID;
    museum_id UUID;
    visit1_id UUID;
    visit2_id UUID;
BEGIN
    -- Get the test user ID
    SELECT id INTO test_user_id FROM users WHERE email = 'user@web.com';
    
    -- Insert a restaurant
    INSERT INTO places (
        name, type, emoji, address, phone, website, 
        opening_hours, highlights, price_range, special_data
    ) VALUES (
        'Bella Vista Restaurant',
        'restaurant',
        '🍽️',
        '123 Main Street, Downtown',
        '+1-555-0123',
        'https://bellavista.example.com',
        '{"monday": "11:00-22:00", "tuesday": "11:00-22:00", "wednesday": "11:00-22:00", "thursday": "11:00-22:00", "friday": "11:00-23:00", "saturday": "10:00-23:00", "sunday": "10:00-22:00"}',
        ARRAY['Fresh ingredients', 'Outdoor seating', 'Wine selection'],
        '€€',
        '{"cuisine": "Italian", "priceCategory": "€€", "hasReservation": true, "hasDelivery": true, "hasTakeout": false}'
    ) RETURNING id INTO restaurant_id;
    
    -- Insert menu items for the restaurant
    INSERT INTO menu_items (place_id, name, description, price, category, is_vegetarian, is_vegan, allergens) VALUES
    (restaurant_id, 'Margherita Pizza', 'Classic pizza with tomato, mozzarella, and basil', 12.50, 'pizza', true, false, ARRAY['gluten', 'dairy']),
    (restaurant_id, 'Spaghetti Carbonara', 'Pasta with eggs, cheese, and pancetta', 14.90, 'pasta', false, false, ARRAY['gluten', 'dairy', 'eggs']),
    (restaurant_id, 'Caesar Salad', 'Fresh romaine lettuce with caesar dressing', 9.90, 'salads', true, false, ARRAY['dairy', 'eggs']),
    (restaurant_id, 'Tiramisu', 'Classic Italian dessert with coffee and mascarpone', 6.50, 'desserts', true, false, ARRAY['gluten', 'dairy', 'eggs']);
    
    -- Insert a museum
    INSERT INTO places (
        name, type, emoji, address, phone, website,
        opening_hours, highlights, price_range, special_data
    ) VALUES (
        'Modern Art Museum',
        'museum',
        '🏛️',
        '456 Culture Avenue, Arts District',
        '+1-555-0456',
        'https://modernart.example.com',
        '{"tuesday": "10:00-18:00", "wednesday": "10:00-18:00", "thursday": "10:00-20:00", "friday": "10:00-18:00", "saturday": "10:00-18:00", "sunday": "12:00-17:00"}',
        ARRAY['Contemporary art', 'Interactive exhibits', 'Museum shop'],
        '€€',
        '{"category": "art", "currentExhibitions": ["Digital Renaissance", "Urban Landscapes"], "permanentCollections": ["20th Century Masters", "Local Artists"], "ticketPrice": "15€", "hasAudioGuide": true, "hasGiftShop": true, "isWheelchairAccessible": true}'
    ) RETURNING id INTO museum_id;
    
    -- Insert user place status (visited restaurant, not visited museum)
    INSERT INTO user_place_status (user_id, place_id, is_visited, last_visit, user_rating, visit_count) VALUES
    (test_user_id, restaurant_id, true, NOW() - INTERVAL '3 days', 4.5, 2),
    (test_user_id, museum_id, false, NULL, NULL, 0);
    
    -- Insert restaurant visit
    INSERT INTO visits (
        user_id, place_id, date, place_type, overall_rating, notes, 
        duration_minutes, total_cost, photo_urls, is_public
    ) VALUES (
        test_user_id, restaurant_id, NOW() - INTERVAL '3 days', 'restaurant', 4.5,
        'Great atmosphere and delicious food! The pizza was perfectly crispy.',
        90, 35.80, ARRAY['photo1.jpg', 'photo2.jpg'], true
    ) RETURNING id INTO visit1_id;
    
    -- Insert visit activities for restaurant visit
    INSERT INTO visit_activities (visit_id, name, type, rating, activity_data) VALUES
    (visit1_id, 'Margherita Pizza', 'dish', 5.0, '{"category": "pizza", "price": 12.50, "description": "Perfect crust and fresh basil"}'),
    (visit1_id, 'Spaghetti Carbonara', 'dish', 4.0, '{"category": "pasta", "price": 14.90, "description": "Creamy and authentic"}');
    
    -- Insert another restaurant visit
    INSERT INTO visits (
        user_id, place_id, date, place_type, overall_rating, notes,
        duration_minutes, total_cost, is_public
    ) VALUES (
        test_user_id, restaurant_id, NOW() - INTERVAL '7 days', 'restaurant', 4.0,
        'Second visit - tried the tiramisu this time!',
        75, 28.30, true
    ) RETURNING id INTO visit2_id;
    
    INSERT INTO visit_activities (visit_id, name, type, rating, activity_data) VALUES
    (visit2_id, 'Caesar Salad', 'dish', 4.5, '{"category": "salads", "price": 9.90, "description": "Fresh and crispy"}'),
    (visit2_id, 'Tiramisu', 'dish', 4.0, '{"category": "desserts", "price": 6.50, "description": "Rich and creamy"}');

END $$;