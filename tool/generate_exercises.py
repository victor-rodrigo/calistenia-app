#!/usr/bin/env python3
"""Gera a biblioteca de exercícios de calistenia a partir da Free Exercise DB.

Fonte: https://github.com/yuhonas/free-exercise-db (The Unlicense / domínio público).
Baixa o catálogo, filtra os exercícios de peso corporal, traduz nomes e grupos
musculares para o português, baixa a primeira imagem de cada um e escreve o asset
que o app lê no primeiro uso.

Uso: python3 tool/generate_exercises.py   (a partir da raiz do projeto)
"""

import json
import os
import urllib.request

SRC_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
IMG_BASE = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises"
OUT_DIR = "assets/exercicios"
OUT_JSON = "assets/exercicios_calistenia.json"

OTHER_KEYWORDS = [
    "muscle up", "parallel bar dip", "ring dips", "dips - chest", "one arm chin",
    "band assisted pull", "rocky pull", "side to side chins", "mixed grip chin",
    "gironda", "suspended push",
]

# Isometrias (registradas por tempo); o resto é por repetições.
TEMPO_IDS = {
    "Plank", "Side_Bridge", "Isometric_Chest_Squeezes", "Isometric_Wipers",
    "Isometric_Neck_Exercise_-_Front_And_Back", "Isometric_Neck_Exercise_-_Sides",
}

MUSCLE_PT = {
    "abdominals": "Abdômen", "triceps": "Tríceps", "biceps": "Bíceps",
    "quadriceps": "Quadríceps", "hamstrings": "Posterior de coxa",
    "glutes": "Glúteos", "chest": "Peito", "lats": "Costas",
    "middle back": "Costas", "lower back": "Lombar", "shoulders": "Ombros",
    "neck": "Pescoço", "adductors": "Adutores", "abductors": "Abdutores",
    "calves": "Panturrilha", "forearms": "Antebraço", "traps": "Trapézio",
}

NAME_PT = {
    "3/4 Sit-Up": "Abdominal 3/4",
    "Air Bike": "Bicicleta no ar",
    "Alternate Heel Touchers": "Toque alternado no calcanhar",
    "Band Assisted Pull-Up": "Barra fixa assistida com elástico",
    "Bench Dips": "Mergulho no banco",
    "Bench Jump": "Salto no banco",
    "Bent-Knee Hip Raise": "Elevação de quadril com joelhos flexionados",
    "Body Tricep Press": "Extensão de tríceps com peso corporal",
    "Body-Up": "Elevação de tronco (body-up)",
    "Bodyweight Squat": "Agachamento livre",
    "Bottoms Up": "Elevação de pernas e quadril",
    "Butt Lift (Bridge)": "Ponte de glúteos",
    "Butt-Ups": "Elevação de quadril na prancha",
    "Chin-Up": "Barra supinada",
    "Clock Push-Up": "Flexão relógio",
    "Close-Grip Push-Up off of a Dumbbell": "Flexão com pegada fechada",
    "Cocoons": "Abdominal casulo",
    "Cross-Body Crunch": "Abdominal cruzado",
    "Crunch - Hands Overhead": "Abdominal com braços estendidos",
    "Crunch - Legs On Exercise Ball": "Abdominal com pernas elevadas",
    "Crunches": "Abdominal",
    "Dead Bug": "Abdominal dead bug",
    "Decline Crunch": "Abdominal declinado",
    "Decline Oblique Crunch": "Abdominal oblíquo declinado",
    "Decline Reverse Crunch": "Abdominal reverso declinado",
    "Dips - Chest Version": "Paralelas (foco peito)",
    "Dips - Triceps Version": "Paralelas (foco tríceps)",
    "Double Leg Butt Kick": "Calcanhar aos glúteos (dois pés)",
    "Elbow to Knee": "Cotovelo ao joelho",
    "Fast Skipping": "Pular corda rápido",
    "Flat Bench Leg Pull-In": "Recolhimento de pernas no banco",
    "Flat Bench Lying Leg Raise": "Elevação de pernas deitado no banco",
    "Flutter Kicks": "Chute alternado (flutter kicks)",
    "Freehand Jump Squat": "Agachamento com salto",
    "Frog Sit-Ups": "Abdominal sapo",
    "Gironda Sternum Chins": "Barra Gironda (esterno)",
    "Glute Kickback": "Extensão de glúteo (coice)",
    "Gorilla Chin/Crunch": "Barra com abdominal (gorilla chin)",
    "Handstand Push-Ups": "Flexão parada de mão",
    "Hanging Leg Raise": "Elevação de pernas na barra",
    "Hanging Pike": "Elevação de pernas em L na barra",
    "Hyperextensions With No Hyperextension Bench": "Hiperextensão lombar no chão",
    "Incline Push-Up": "Flexão inclinada",
    "Incline Push-Up Close-Grip": "Flexão inclinada fechada",
    "Incline Push-Up Medium": "Flexão inclinada (pegada média)",
    "Incline Push-Up Reverse Grip": "Flexão inclinada (pegada invertida)",
    "Incline Push-Up Wide": "Flexão inclinada aberta",
    "Isometric Chest Squeezes": "Contração isométrica de peito",
    "Isometric Neck Exercise - Front And Back": "Isometria de pescoço (frente e trás)",
    "Isometric Neck Exercise - Sides": "Isometria de pescoço (laterais)",
    "Isometric Wipers": "Isometria de peito (wipers)",
    "Jackknife Sit-Up": "Abdominal canivete",
    "Janda Sit-Up": "Abdominal Janda",
    "Kipping Muscle Up": "Muscle up com impulso (kipping)",
    "Knee Tuck Jump": "Salto com joelhos ao peito",
    "Lateral Bound": "Salto lateral",
    "Leg Lift": "Elevação de pernas",
    "Leg Pull-In": "Recolhimento de pernas",
    "Mixed Grip Chin": "Barra com pegada mista",
    "Muscle Up": "Muscle up",
    "Natural Glute Ham Raise": "Flexão nórdica (glúteo-femoral)",
    "Oblique Crunches": "Abdominal oblíquo",
    "Oblique Crunches - On The Floor": "Abdominal oblíquo no chão",
    "One Arm Chin-Up": "Barra supinada com um braço",
    "Parallel Bar Dip": "Paralelas",
    "Plank": "Prancha",
    "Plyo Push-up": "Flexão pliométrica",
    "Pullups": "Barra fixa",
    "Push Up to Side Plank": "Flexão com prancha lateral",
    "Push-Up Wide": "Flexão aberta",
    "Push-Ups - Close Triceps Position": "Flexão fechada (tríceps)",
    "Push-Ups With Feet Elevated": "Flexão declinada (pés elevados)",
    "Pushups": "Flexão",
    "Pushups (Close and Wide Hand Positions)": "Flexão (pegada fechada e aberta)",
    "Reverse Crunch": "Abdominal reverso",
    "Ring Dips": "Paralelas nas argolas",
    "Rocket Jump": "Salto foguete",
    "Rocky Pull-Ups/Pulldowns": "Barra Rocky",
    "Russian Twist": "Rotação russa",
    "Scissors Jump": "Salto tesoura",
    "Seated Flat Bench Leg Pull-In": "Recolhimento de pernas sentado no banco",
    "Seated Leg Tucks": "Recolhimento de pernas sentado",
    "Side Bridge": "Prancha lateral (ponte)",
    "Side Jackknife": "Canivete lateral",
    "Side To Side Chins": "Barra lado a lado",
    "Single Leg Butt Kick": "Calcanhar ao glúteo (uma perna)",
    "Single Leg Glute Bridge": "Ponte de glúteo unilateral",
    "Single-Arm Push-Up": "Flexão com um braço",
    "Sit-Up": "Abdominal completo",
    "Spider Crawl": "Caminhada aranha",
    "Split Jump": "Salto afundo",
    "Standing Long Jump": "Salto horizontal",
    "Standing Towel Triceps Extension": "Extensão de tríceps com toalha",
    "Star Jump": "Polichinelo estrela",
    "Step-up with Knee Raise": "Step-up com elevação de joelho",
    "Suspended Push-Up": "Flexão suspensa",
    "Tuck Crunch": "Abdominal agrupado",
    "V-Bar Pullup": "Barra fixa com triângulo",
    "Wide-Grip Rear Pull-Up": "Barra fixa aberta atrás da nuca",
    "Wind Sprints": "Corridas curtas (wind sprints)",
}


def selecionar(catalogo):
    out = []
    for x in catalogo:
        eq = x.get("equipment")
        nome_low = x["name"].lower()
        if eq == "body only" and x.get("category") != "stretching":
            out.append(x)
        elif eq == "other" and any(k in nome_low for k in OTHER_KEYWORDS):
            out.append(x)
    out.sort(key=lambda x: x["name"])
    return out


def main():
    print("baixando catálogo...")
    with urllib.request.urlopen(SRC_URL, timeout=60) as r:
        catalogo = json.load(r)

    selecionados = selecionar(catalogo)
    print(f"selecionados: {len(selecionados)}")

    faltando = [x["name"] for x in selecionados if x["name"] not in NAME_PT]
    if faltando:
        raise SystemExit(f"sem tradução para: {faltando}")

    os.makedirs(OUT_DIR, exist_ok=True)
    registros = []

    for x in selecionados:
        ex_id = x["id"]
        musculos = x.get("primaryMuscles") or []
        grupo = MUSCLE_PT.get(musculos[0]) if musculos else None
        tipo = "tempo" if ex_id in TEMPO_IDS else "reps"

        imagem_rel = None
        imagens = x.get("images") or []
        if imagens:
            destino = os.path.join(OUT_DIR, f"{ex_id}.jpg")
            url = f"{IMG_BASE}/{imagens[0]}"
            try:
                urllib.request.urlretrieve(url, destino)
                imagem_rel = f"{OUT_DIR}/{ex_id}.jpg"
            except Exception as e:
                print(f"  imagem falhou ({ex_id}): {e}")

        registros.append({
            "nome": NAME_PT[x["name"]],
            "nomeOriginal": x["name"],
            "grupoMuscular": grupo,
            "tipo": tipo,
            "imagem": imagem_rel,
        })

    registros.sort(key=lambda r: r["nome"])
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(registros, f, ensure_ascii=False, indent=2)

    com_img = sum(1 for r in registros if r["imagem"])
    print(f"gerado {OUT_JSON}: {len(registros)} exercícios, {com_img} com imagem")


if __name__ == "__main__":
    main()
