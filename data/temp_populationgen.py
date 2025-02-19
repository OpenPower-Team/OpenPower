from openai import OpenAI
import csv

# Best practice: Використовуйте змінні середовища для API-ключів
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="",  # Замініть на свій API-ключ або використовуйте змінну середовища
)

def generate_population_data(regions_prompt_list, country_code):
    """Генерує дані про населення для списку регіонів за допомогою OpenAI API."""
    if not regions_prompt_list or not isinstance(regions_prompt_list, list):
        raise ValueError("regions_prompt_list має бути непорожнім списком")

    if not country_code or not isinstance(country_code, str):
        raise ValueError("country_code має бути непорожнім рядком")

    regions_string = ", ".join(regions_prompt_list)
    prompt = f"""For the following regions in country '{country_code}', provide population data for 2001: {regions_string}

Output Format (Strict):
POP_15,POP_15_65,POP_65;...
*   Data must be real and realistical as much as possible.
*   POP_15: Population under 15.
*   POP_15_65: Population 15-65.
*   POP_65: Population over 65.
*   Use natural numbers.
*   Separate regions with semicolons (;).
*   Data cannot be "N/A,N/A,N/A", only numbers.
*   Output MUST follow the region order in the input.
*   DO NOT include any text other than the comma-separated numbers and semicolons. No explanations, no region names, no extra spaces."""
    
    try:
        completion = client.chat.completions.create(
            model="deepseek/deepseek-chat:free",
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )
    except Exception as e:
        print(f"API call failed: {e}")
        return []
    
    attempts = 0
    max_attempts = 3
    while attempts < max_attempts:
        try:
            model_output = completion.choices[0].message.content
            print(f"Model output:\n {model_output}")
            break  # Вихід із циклу, якщо доступ до результату пройшов успішно
        except Exception as e:
            print(f"Error accessing model output: {e}. Repeating prompt...")
            try:
                completion = client.chat.completions.create(
                    model="deepseek/deepseek-chat:free",
                    messages=[
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ]
                )
            except Exception as inner_e:
                print(f"Retry API call failed: {inner_e}")
            attempts += 1
    else:
        print("Не вдалося отримати результат від моделі після кількох спроб.")
        return []
    
    response_content = completion.choices[0].message.content
    population_data_list = []
    responses = [r.strip() for r in response_content.split(';') if r.strip()]
    for region_response in responses:
        try:
            pop_15, pop_15_65, pop_65 = map(int, region_response.split(','))
            population_data_list.append((pop_15, pop_15_65, pop_65))
        except ValueError:
            print(f"Error parsing response: '{region_response}'. Expected format: 'POP_15,POP_15_65,POP_65'")
            population_data_list.append((None, None, None))
    return population_data_list

def update_csv_with_population(csv_filepath):
    """Оновлює файл DataRegions.csv з даними про населення лише для рядків, де дані відсутні.
    У даному варіанті файл зчитується один раз, зміни накопичуються в пам’яті, а після обробки кожного батчу
    відбувається перезапис у файл (тобто, перезаписується весь файл, але з уже накопиченими змінами)."""
    if not csv_filepath or not isinstance(csv_filepath, str):
        raise ValueError("csv_filepath має бути непорожнім рядком")

    try:
        with open(csv_filepath, 'r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            fieldnames = reader.fieldnames
            if not fieldnames:
                print("Помилка: CSV файл порожній або відсутній заголовок.")
                return
            rows = list(reader)
    except FileNotFoundError:
        print(f"Помилка: Файл не знайдено за шляхом {csv_filepath}")
        return
    except Exception as e:
        print(f"Помилка при зчитуванні CSV файлу: {e}")
        return

    total_regions = len(rows)
    processed_regions = 0
    batch_size = 10  # обробляємо групами по десять
    for i in range(0, total_regions, batch_size):
        batch_indices = list(range(i, min(i + batch_size, total_regions)))
        regions_to_process = []
        indices_to_update = []  # зберігаємо індекси рядків, що потребують оновлення

        for idx in batch_indices:
            region_info = rows[idx]
            if not region_info.get('REGION_NAME'):
                print(f"Пропуск недійсного запису регіону: {region_info}")
                continue

            pop_15 = region_info.get('POP_15')
            pop_15_65 = region_info.get('POP_15_65')
            pop_65 = region_info.get('POP_65')

            if (not pop_15 or str(pop_15).strip() == '' or
                not pop_15_65 or str(pop_15_65).strip() == '' or
                not pop_65 or str(pop_65).strip() == ''):
                regions_to_process.append(region_info['REGION_NAME'])
                indices_to_update.append(idx)

        if not regions_to_process:
            print(f"У групі {i // batch_size + 1} немає регіонів для оновлення даних населення.")
            continue

        print(f"Група {i // batch_size + 1}. Регіони для обробки: {', '.join(regions_to_process)}")

        # Визначення коду країни з першого регіону, що потребує оновлення
        region_info_for_country = rows[indices_to_update[0]]
        string_id = region_info_for_country.get('STRING_ID', '')
        if '-' in string_id:
            country_code = string_id.split('-')[0]
        else:
            country_code = region_info_for_country.get('PLTC_OWNER_ID')
        if not country_code:
            print(f"Помилка: не вдалося визначити код країни для групи {i // batch_size + 1}. Пропускаємо групу.")
            continue

        population_data_list = generate_population_data(regions_to_process, country_code)
        if population_data_list and len(population_data_list) == len(indices_to_update):
            for j, idx in enumerate(indices_to_update):
                pop_15, pop_15_65, pop_65 = population_data_list[j]
                if pop_15 is not None and pop_15_65 is not None and pop_65 is not None:
                    rows[idx]['POP_15'] = pop_15
                    rows[idx]['POP_15_65'] = pop_15_65
                    rows[idx]['POP_65'] = pop_65
                    processed_regions += 1
                    print(f"Успішно оновлено регіон: {rows[idx]['REGION_NAME']}")
                else:
                    print(f"Пропуск оновлення для регіону: {rows[idx]['REGION_NAME']} через недійсні дані")
        else:
            print(f"Помилка: розмір відповіді API не співпадає з кількістю регіонів у групі {i // batch_size + 1}.")
            continue

        # Після обробки поточного батчу перезаписуємо весь файл із накопиченими змінами
        try:
            with open(csv_filepath, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(rows)
            print(f"Група {i // batch_size + 1} успішно зафіксована у файлі.")
        except Exception as e:
            print(f"Помилка при записі групи {i // batch_size + 1} у CSV: {str(e)}")
            return

    print(f"Оновлено {processed_regions} регіонів з {total_regions} загалом.")

csv_file_path = 'data/DataRegions.csv'
update_csv_with_population(csv_file_path)
