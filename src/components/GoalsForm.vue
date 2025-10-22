<template>
  <div class="goals-container">
    <h3 class="form-section-title">🎯 Twoje cele</h3>

    <form @submit.prevent="saveGoals" class="goals-form">
      <div class="form-group">
        <label class="form-label">Kalorie (max)</label>
        <input
          type="number"
          v-model.number="goals.calories_goal"
          min="500"
          max="5000"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Kroki (minimum)</label>
        <input
          type="number"
          v-model.number="goals.steps_goal"
          min="1000"
          max="50000"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Białko (minimum, g)</label>
        <input
          type="number"
          v-model.number="goals.protein_goal"
          min="10"
          max="300"
          step="0.1"
          class="number-input-simple"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Waga docelowa (kg)</label>
        <input
          type="number"
          v-model.number="goals.target_weight"
          min="30"
          max="200"
          step="0.1"
          class="number-input-simple"
        />
      </div>

      <!-- Obliczenia deficytu kalorycznego -->
      <div
        v-if="goals.target_weight && currentWeight"
        class="deficit-calculator"
      >
        <h4 class="calculator-title">📊 Plan redukcji wagi</h4>
        <div class="calculator-stats">
          <div class="stat-item">
            <span class="stat-label">Aktualna waga:</span>
            <span class="stat-value">{{ currentWeight }}kg</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Waga docelowa:</span>
            <span class="stat-value">{{ goals.target_weight }}kg</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Do zrzucenia:</span>
            <span
              class="stat-value"
              :class="{
                positive: weightToLose > 0,
                negative: weightToLose < 0,
              }"
            >
              {{ weightToLose > 0 ? "+" : "" }}{{ weightToLose.toFixed(1) }}kg
            </span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Dni do końca:</span>
            <span class="stat-value">{{ daysRemaining }}</span>
          </div>
          <div class="stat-item highlight">
            <span class="stat-label">Dzienny deficyt:</span>
            <span class="stat-value">{{ dailyDeficit }} kcal</span>
          </div>
        </div>
      </div>

      <button type="submit" class="action-btn">
        <span class="btn-icon">💾</span>
        Zapisz cele
      </button>
    </form>
  </div>
</template>

<script>
import { reactive, onMounted, computed } from "vue";
import { supabase } from "../supabase.js";

export default {
  name: "GoalsForm",
  props: {
    userId: {
      type: Number,
      required: true,
    },
    personData: {
      type: Object,
      required: true,
    },
  },
  emits: ["goals-saved"],
  setup(props, { emit }) {
    const goals = reactive({
      calories_goal: 2000,
      steps_goal: 10000,
      protein_goal: 100.0,
      target_weight: null,
    });

    // Oblicz aktualną wagę (najnowszy wpis)
    const currentWeight = computed(() => {
      if (!props.personData?.dailyStats) return null;

      const weightEntries = props.personData.dailyStats
        .filter((stat) => stat.weight !== null && stat.weight !== undefined)
        .sort((a, b) => new Date(b.date) - new Date(a.date));

      return weightEntries.length > 0 ? weightEntries[0].weight : null;
    });

    // Oblicz ile kg trzeba zrzucić
    const weightToLose = computed(() => {
      if (!currentWeight.value || !goals.target_weight) return 0;
      return currentWeight.value - goals.target_weight;
    });

    // Oblicz dni do 31 stycznia 2026
    const daysRemaining = computed(() => {
      const today = new Date();
      const challengeEnd = new Date("2026-01-31");
      const timeDiff = challengeEnd.getTime() - today.getTime();
      return Math.max(0, Math.ceil(timeDiff / (1000 * 3600 * 24)));
    });

    // Oblicz dzienny deficyt kaloryczny (1kg = 7000 kcal)
    const dailyDeficit = computed(() => {
      if (weightToLose.value <= 0 || daysRemaining.value <= 0) return 0;
      const totalCaloriesToBurn = weightToLose.value * 7000;
      return Math.round(totalCaloriesToBurn / daysRemaining.value);
    });

    const loadGoals = async () => {
      try {
        const { data, error } = await supabase
          .from("user_goals")
          .select("*")
          .eq("user_id", props.userId)
          .single();

        if (error && error.code !== "PGRST116") {
          throw error;
        }

        if (data) {
          Object.assign(goals, {
            calories_goal: data.calories_goal || 2000,
            steps_goal: data.steps_goal || 10000,
            protein_goal: data.protein_goal || 100.0,
            target_weight: data.target_weight || null,
          });
        }
      } catch (error) {
        console.error("Error loading goals:", error);
      }
    };

    const saveGoals = async () => {
      try {
        const { error } = await supabase.from("user_goals").upsert(
          {
            user_id: props.userId,
            calories_goal: goals.calories_goal,
            steps_goal: goals.steps_goal,
            protein_goal: goals.protein_goal,
            target_weight: goals.target_weight,
            supplements_goal: true, // Zawsze true
            updated_at: new Date().toISOString(),
          },
          {
            onConflict: "user_id",
            ignoreDuplicates: false,
          }
        );

        if (error) throw error;

        emit("goals-saved", {
          ...goals,
          supplements_goal: true, // Zawsze true
        });
      } catch (error) {
        console.error("Error saving goals:", error);
      }
    };

    onMounted(() => {
      loadGoals();
    });

    return {
      goals,
      saveGoals,
      currentWeight,
      weightToLose,
      daysRemaining,
      dailyDeficit,
    };
  },
};
</script>

<style scoped>
.goals-container {
  background: #2c2c2c;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
}

.form-section-title {
  color: #fff;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 20px;
  font-family: "Poppins", sans-serif;
}

.goals-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  color: #fff;
  font-size: 14px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
}

.number-input-simple {
  padding: 12px 16px;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-family: "Poppins", sans-serif;
  transition: border-color 0.2s;
}

.number-input-simple:focus {
  outline: none;
  border-color: #00c073;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.checkbox-input {
  width: 18px;
  height: 18px;
  accent-color: #00c073;
}

.checkbox-text {
  color: #fff;
  font-size: 14px;
  font-family: "Poppins", sans-serif;
}

.action-btn {
  padding: 14px 20px;
  background: linear-gradient(135deg, #00c073, #00a060);
  border: none;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(255, 127, 39, 0.3);
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(255, 127, 39, 0.4);
}

.btn-icon {
  font-size: 18px;
}

/* Kalkulator deficytu */
.deficit-calculator {
  background: #1a1a1a;
  border-radius: 12px;
  padding: 20px;
  margin-top: 20px;
  border: 1px solid #333;
}

.calculator-title {
  color: #00c073;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 16px;
  font-family: "Poppins", sans-serif;
}

.calculator-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #333;
}

.stat-item:last-child {
  border-bottom: none;
}

.stat-item.highlight {
  background: rgba(0, 192, 115, 0.1);
  border-radius: 8px;
  padding: 12px;
  border-bottom: none;
  margin-top: 8px;
}

.stat-label {
  color: #ccc;
  font-size: 14px;
  font-weight: 500;
  font-family: "Poppins", sans-serif;
}

.stat-value {
  color: #fff;
  font-weight: 600;
  font-size: 16px;
  font-family: "Poppins", sans-serif;
}

.stat-value.positive {
  color: #ff4444; /* Czerwony dla przybrania wagi */
}

.stat-value.negative {
  color: #00c073; /* Zielony dla utraty wagi */
}

.stat-item.highlight .stat-value {
  color: #00c073;
  font-size: 18px;
}
</style>
