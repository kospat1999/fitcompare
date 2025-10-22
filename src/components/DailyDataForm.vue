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
import { reactive, watch } from "vue";

export default {
  name: "DailyDataForm",
  props: {
    selectedDate: {
      type: String,
      required: true,
    },
    personData: {
      type: Object,
      required: true,
    },
  },
  emits: ["daily-stats-saved"],
  setup(props, { emit }) {
    const dailyStats = reactive({
      calories: 0,
      steps: 0,
      protein: 0,
      weight: null,
      supplements: false,
    });

    // Reset do wartości domyślnych (tylko gdy nie ma danych)
    const resetToDefaults = () => {
      Object.assign(dailyStats, {
        calories: 0,
        steps: 0,
        protein: 0,
        weight: null,
        supplements: false,
      });
    };

    const saveDailyStats = () => {
      emit("daily-stats-saved", { ...dailyStats });
    };

    // Funkcja do ładowania danych dla wybranego dnia
    const loadDataForDate = (date) => {
      console.log("DailyDataForm: loadDataForDate called for:", date);
      console.log("DailyDataForm: personData:", props.personData);

      if (!props.personData || !props.personData.dailyStats) {
        console.log("No personData or dailyStats available");
        resetToDefaults();
        return;
      }

      // Znajdź dane dla tego dnia
      const statsForDate = props.personData.dailyStats.find(
        (stat) => stat.date === date
      );

      console.log("DailyDataForm: Found stats for date:", statsForDate);

      if (statsForDate) {
        console.log("DailyDataForm: Setting form data from existing stats");
        Object.assign(dailyStats, {
          calories: statsForDate.calories || 0,
          steps: statsForDate.steps || 0,
          protein: statsForDate.protein || 0,
          weight:
            statsForDate.weight !== undefined ? statsForDate.weight : null,
          supplements: statsForDate.supplements === true,
        });
      } else {
        console.log("DailyDataForm: No existing data, resetting to defaults");
        resetToDefaults();
      }
    };

    // Obserwuj zmiany wybranego dnia i ładuj dane
    watch(
      () => props.selectedDate,
      (newDate) => {
        console.log("DailyDataForm: selectedDate changed to:", newDate);
        loadDataForDate(newDate);
      },
      { immediate: true }
    );

    // Obserwuj zmiany personData
    watch(
      () => props.personData,
      () => {
        console.log(
          "DailyDataForm: personData changed, reloading for:",
          props.selectedDate
        );
        loadDataForDate(props.selectedDate);
      },
      { deep: true }
    );

    return {
      dailyStats,
      saveDailyStats,
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
  border-color: #00c073;
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
  accent-color: #00c073;
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
  background: linear-gradient(145deg, #00c073, #00a060);
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
  background: linear-gradient(145deg, #00a060, #008050);
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
