import random
from datetime import datetime

# Seasonal produce
produce_by_season = {
    'summer': {
        'fruits': ['mango', 'papaya', 'watermelon', 'jamun'],
        'vegetables': ['cucumber', 'bottle gourd', 'ridge gourd', 'brinjal']
    },
    'monsoon': {
        'fruits': ['guava', 'custard apple', 'pear'],
        'vegetables': ['okra', 'beans', 'spinach', 'methi']
    },
    'winter': {
        'fruits': ['orange', 'grapes', 'kiwi'],
        'vegetables': ['carrot', 'beetroot', 'cabbage', 'cauliflower']
    }
}

# Always available staples
staples = ['potato', 'tomato', 'onion']

# Sprouts and pulses
sprouts = ['moong sprouts', 'matki sprouts', 'kala chana sprouts']
pulses = ['rajma', 'kabuli chana', 'toor dal', 'lobia', 'masoor dal', 'horse gram', 'moth beans']

# Cooking-only produce
cooking_essentials = [
    'green chili', 'fresh ginger', 'garlic', 'coriander leaves',
    'curry leaves', 'spring onion', 'mint leaves', 'raw turmeric', 'lime/lemon', 'raw mango'
]

def get_current_season():
    month = datetime.now().month
    if 3 <= month <= 5:
        return 'summer'
    elif 6 <= month <= 9:
        return 'monsoon'
    else:
        return 'winter'

def generate_weekly_basket(family_size):
    season = get_current_season()
    weekly_basket = []
    staple_count = {s: 0 for s in staples}
    pulse_days = random.sample(range(7), 4)
    sprout_days = random.sample(range(7), 5)

    for day in range(7):
        fruits = random.sample(produce_by_season[season]['fruits'], 2)
        other_veggies = random.sample(produce_by_season[season]['vegetables'], 4)

        selected_veggies = []
        for s in staples:
            if staple_count[s] < 3 and random.random() < 0.4:
                selected_veggies.append(s)
                staple_count[s] += 1
        while len(selected_veggies) < 4:
            for veg in other_veggies:
                if veg not in selected_veggies:
                    selected_veggies.append(veg)
                    if len(selected_veggies) == 4:
                        break
        if day == 6:
            for s in staples:
                if staple_count[s] < 3:
                    selected_veggies[random.randint(0, 3)] = s
                    staple_count[s] += 1

        breakfast_items = {
            'fruits': [fruits[0]],
            'sprouts': f"{random.choice(sprouts)} ({family_size * 100}g)" if day in sprout_days else None
        }

        pulse = random.choice(pulses) if day in pulse_days else None

        # Include cooking-only produce (rotated)
        cooking_items = random.sample(cooking_essentials, 4)

        basket = {
            'day': f'Day {day + 1}',
            'breakfast': breakfast_items,
            'lunch': {
                'vegetables': selected_veggies[:2],
                'pulse': pulse if random.choice([True, False]) else None,
                'rice': family_size * 150,
                'roti': family_size * 2,
            },
            'snack': {
                'fruit': fruits[1],
            },
            'dinner': {
                'vegetables': selected_veggies[2:],
                'pulse': pulse if random.choice([False, True]) else None,
                'roti': family_size * 2,
            },
            'cooking_ingredients': cooking_items
        }

        weekly_basket.append(basket)

    return weekly_basket


