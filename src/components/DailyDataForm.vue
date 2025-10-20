<template>
  <div class="daily-data-form">
    <h3 class="form-section-title">📊 Dane dzienne</h3>

    <div class="form-group">
      <label class="form-label">Kalorie</label>
      <input
        type="number"
        v-model.number="dailyStats.calories"
        min="0"
        class="number-input-simple"
      />
    </div>

    <div class="form-group">
      <label class="form-label">Kroki</label>
      <input
        type="number"
        v-model.number="dailyStats.steps"
        min="0"
        class="number-input-simple"
      />
    </div>

    <div class="form-group">
      <label class="form-label">Białko (g)</label>
      <input
        type="number"
        v-model.number="dailyStats.protein"
        min="0"
        step="0.1"
        class="number-input-simple"
      />
    </div>

    <div class="form-group">
      <label class="form-label">Waga (kg) - opcjonalna</label>
      <input
        type="number"
        v-model.number="dailyStats.weight"
        min="0"
        step="0.1"
        class="number-input-simple"
      />
    </div>

    <div class="form-group">
      <label class="form-label">Suplementy</label>
      <div class="checkbox-container">
        <input
          type="checkbox"
          v-model="dailyStats.supplements"
          class="checkbox-input"
        />
        <span class="checkbox-label">Tak</span>
      </div>
    </div>

    <button class="action-btn" @click="saveDailyStats">
      <span class="btn-icon">💾</span>
      Zapisz dane dzienne
    </button>
  </div>
</template>

<script>
import { reactive, watch, defineExpose } from "vue";

export default {
  name: "DailyDataForm",
  props: {
    selectedDate: {
      type: String,
      required: true,
    },
  },
  emits: ["daily-stats-saved", "load-stats-for-date"],
  setup(props, { emit }) {
    const dailyStats = reactive({
      calories: 0,
      steps: 0,
      protein: 0,
      weight: 70.5,
      supplements: false,
    });

    // Reset do wartości domyślnych (tylko gdy nie ma danych)
    const resetToDefaults = () => {
      Object.assign(dailyStats, {
        calories: 0,
        steps: 0,
        protein: 0,
        weight: 70.5,
        supplements: false,
      });
    };

    const saveDailyStats = () => {
      emit("daily-stats-saved", { ...dailyStats });
    };

    // Obserwuj zmiany wybranego dnia
    watch(
      () => props.selectedDate,
      (newDate) => {
        // Emituj event żeby rodzic mógł załadować dane dla tego dnia
        emit("load-stats-for-date", newDate);
      },
      { immediate: true }
    );

    // Funkcja do ustawiania danych z rodzica
    const setStatsData = (statsData) => {
      console.log("setStatsData called with:", statsData);
      if (statsData) {
        console.log("Setting form data from existing stats");
        Object.assign(dailyStats, {
          calories: statsData.calories || 0,
          steps: statsData.steps || 0,
          protein: statsData.protein || 0,
          weight: statsData.weight || 70.5,
          supplements: statsData.supplements === true, // Dokładnie true/false
        });
      } else {
        console.log("No existing data, resetting to defaults");
        resetToDefaults();
      }
    };

    // Eksponuj metody dla rodzica
    defineExpose({
      setStatsData,
    });

    return {
      dailyStats,
      saveDailyStats,
      setStatsData,
    };
  },
};
</script>

<style scoped>
.daily-data-form {
  background-color: #2c2c2c;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
}

.form-section-title {
  color: white;
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  color: white;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 8px;
  display: block;
}

.number-input-simple {
  width: 100%;
  padding: 14px 12px;
  background: linear-gradient(145deg, #1a1a1a, #2a2a2a);
  border: 2px solid #333;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
}

.number-input-simple:focus {
  outline: none;
  border-color: #ff7f27;
  background: linear-gradient(145deg, #2a2a2a, #1a1a1a);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3),
    0 0 0 3px rgba(255, 127, 39, 0.2);
  transform: translateY(-1px);
}

.number-input-simple:hover {
  border-color: #555;
  transform: translateY(-1px);
}

.checkbox-container {
  display: flex;
  align-items: center;
  gap: 10px;
}

.checkbox-input {
  width: 20px;
  height: 20px;
  accent-color: #ff7f27;
  cursor: pointer;
  transition: all 0.3s ease;
}

.checkbox-input:hover {
  transform: scale(1.1);
}

.checkbox-label {
  color: white;
  font-size: 14px;
}

.action-btn {
  width: 100%;
  padding: 16px 20px;
  background: linear-gradient(145deg, #ff7f27, #e66a1a);
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  transition: all 0.3s ease;
  box-shadow: 0 6px 16px rgba(255, 127, 39, 0.4);
}

.action-btn:hover {
  background: linear-gradient(145deg, #e66a1a, #d45a0a);
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(255, 127, 39, 0.5);
}

.action-btn:active {
  transform: translateY(0);
  box-shadow: 0 4px 12px rgba(255, 127, 39, 0.4);
}

.btn-icon {
  font-size: 18px;
}
</style>
