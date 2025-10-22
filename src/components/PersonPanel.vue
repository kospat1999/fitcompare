<template>
  <div class="person-panel">
    <div class="person-header">
      <h3 class="person-title">{{ person.name }}</h3>
      <button class="dumbbell-btn">
        <img
          :src="person.avatar || '/dogpatka.jpg'"
          :alt="person.name"
          class="avatar-image"
        />
      </button>
    </div>

    <div class="trainings-section">
      <h4 class="section-title">TRENINGI - {{ formatSelectedDate }}</h4>
      <div v-if="filteredTrainings.length > 0">
        <div
          v-for="(training, index) in filteredTrainings"
          :key="index"
          class="training-item"
        >
          <div class="training-icon">💪</div>
          <div class="training-details">
            <div class="training-name">{{ training.type }}</div>
            <div class="training-duration">
              <span>🕐</span>
              <span>{{ training.duration }} min</span>
            </div>
            <!-- Szczegóły treningu -->
            <div v-if="training.details" class="training-specs">
              <div v-if="training.details.gymType" class="training-spec">
                <span class="spec-icon">🏋️‍♂️</span>
                <span class="spec-text">{{ training.details.gymType }}</span>
              </div>
              <div v-if="training.details.floors" class="training-spec">
                <span class="spec-icon">🏢</span>
                <span class="spec-text"
                  >{{ training.details.floors }} pięter</span
                >
              </div>
            </div>
          </div>
          <div class="training-actions">
            <button
              class="delete-btn"
              @click="removeTraining(index)"
              title="Usuń"
            >
              🗑️
            </button>
          </div>
        </div>
      </div>
      <div v-else class="no-trainings">
        {{ selectedDate ? "Brak treningów w tym dniu" : "Brak treningów" }}
      </div>
    </div>

    <div class="metrics-grid">
      <div
        class="metric-card"
        :class="{
          'goal-achieved':
            hasTrainingForSelectedDate || isRestDayForSelectedDate,
          'goal-not-achieved':
            !hasTrainingForSelectedDate && !isRestDayForSelectedDate,
        }"
      >
        <div class="metric-label">
          <span class="metric-icon">💪</span>
          <span>Trening</span>
        </div>
        <div class="metric-value">
          {{
            hasTrainingForSelectedDate
              ? "Zrobiony"
              : isRestDayForSelectedDate
              ? "Rest day"
              : "Nie zrobiony"
          }}
        </div>
      </div>

      <div
        class="metric-card"
        :class="{
          'goal-achieved': isCaloriesGoalAchieved,
          'goal-not-achieved': !isCaloriesGoalAchieved,
        }"
      >
        <div class="metric-label">
          <span class="metric-icon">🔥</span>
          <span>Kalorie</span>
        </div>
        <div class="metric-value">{{ getSelectedDateCalories }} kcal</div>
        <div class="goal-info">
          {{ getSelectedDateCalories }}/{{ goals.calories_goal }} kcal
        </div>
      </div>

      <div
        class="metric-card"
        :class="{
          'goal-achieved': isStepsGoalAchieved,
          'goal-not-achieved': !isStepsGoalAchieved,
        }"
      >
        <div class="metric-label">
          <span class="metric-icon">👟</span>
          <span>Kroki</span>
        </div>
        <div class="metric-value">{{ getSelectedDateSteps }}</div>
        <div class="goal-info">
          {{ getSelectedDateSteps }}/{{ goals.steps_goal }}
        </div>
      </div>

      <div
        class="metric-card"
        :class="{
          'goal-achieved': isProteinGoalAchieved,
          'goal-not-achieved': !isProteinGoalAchieved,
        }"
      >
        <div class="metric-label">
          <span class="metric-icon">🥩</span>
          <span>Białko</span>
        </div>
        <div class="metric-value">{{ getSelectedDateProtein }}g</div>
        <div class="goal-info">
          {{ getSelectedDateProtein }}/{{ goals.protein_goal }}g
        </div>
      </div>

      <div
        class="metric-card"
        :class="{
          'goal-achieved': isSupplementsGoalAchieved,
          'goal-not-achieved': !isSupplementsGoalAchieved,
        }"
      >
        <div class="metric-label">
          <span class="metric-icon">💊</span>
          <span>Suplementy</span>
        </div>
        <button class="supplement-status">
          {{ getSelectedDateSupplements ? "Tak" : "Nie" }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "PersonPanel",
  props: {
    person: {
      type: Object,
      required: true,
    },
    personIndex: {
      type: Number,
      required: true,
    },
    selectedDate: {
      type: String,
      default: null,
    },
    goals: {
      type: Object,
      default: () => ({
        training_time_goal: 60,
        calories_goal: 2000,
        steps_goal: 10000,
        protein_goal: 100.0,
      }),
    },
  },
  emits: ["update-person", "remove-training"],
  computed: {
    filteredTrainings() {
      if (!this.selectedDate) {
        return this.person.trainings;
      }
      return this.person.trainings.filter(
        (training) => training.date === this.selectedDate
      );
    },
    formatSelectedDate() {
      if (!this.selectedDate) return "";
      const date = new Date(this.selectedDate);
      return date.toLocaleDateString("pl-PL", {
        day: "numeric",
        month: "short",
      });
    },
    getSelectedDateTrainingTime() {
      if (!this.selectedDate) return this.person.metrics.trainingTime;
      const trainingsForDate = this.person.trainings.filter(
        (training) => training.date === this.selectedDate
      );
      return trainingsForDate.reduce(
        (total, training) => total + training.duration,
        0
      );
    },
    getSelectedDateCalories() {
      if (!this.selectedDate) return this.person.metrics.calories;
      const statsForDate = this.person.dailyStats?.find(
        (stat) => stat.date === this.selectedDate
      );
      return statsForDate?.calories || 0;
    },
    getSelectedDateSteps() {
      if (!this.selectedDate) return this.person.metrics.steps;
      const statsForDate = this.person.dailyStats?.find(
        (stat) => stat.date === this.selectedDate
      );
      return statsForDate?.steps || 0;
    },
    getSelectedDateProtein() {
      if (!this.selectedDate) return this.person.metrics.protein;
      const statsForDate = this.person.dailyStats?.find(
        (stat) => stat.date === this.selectedDate
      );
      return statsForDate?.protein || 0;
    },
    getSelectedDateSupplements() {
      if (!this.selectedDate) return this.person.metrics.supplements;
      const statsForDate = this.person.dailyStats?.find(
        (stat) => stat.date === this.selectedDate
      );
      return statsForDate?.supplements || false;
    },
    hasTrainingForSelectedDate() {
      if (!this.selectedDate) return this.person.trainings.length > 0;
      return this.person.trainings.some(
        (training) => training.date === this.selectedDate
      );
    },
    isRestDayForSelectedDate() {
      if (!this.selectedDate) return this.person.metrics.restDay;
      const statsForDate = this.person.dailyStats?.find(
        (stat) => stat.date === this.selectedDate
      );
      return statsForDate?.restDay === true;
    },
    // Funkcje sprawdzania osiągnięć
    isTrainingGoalAchieved() {
      return this.getSelectedDateTrainingTime >= this.goals.training_time_goal;
    },
    isCaloriesGoalAchieved() {
      return this.getSelectedDateCalories <= this.goals.calories_goal;
    },
    isStepsGoalAchieved() {
      return this.getSelectedDateSteps >= this.goals.steps_goal;
    },
    isProteinGoalAchieved() {
      return this.getSelectedDateProtein >= this.goals.protein_goal;
    },
    isSupplementsGoalAchieved() {
      return this.getSelectedDateSupplements === true;
    },
  },
  methods: {
    removeTraining(index) {
      if (confirm("Czy na pewno chcesz usunąć ten trening?")) {
        this.$emit("remove-training", this.personIndex, index);
      }
    },
  },
};
</script>

<style scoped>
.person-panel {
  background-color: #2c2c2c;
  border-radius: 12px;
  padding: 20px;
  margin: 10px;
  flex: 1;
  min-width: 300px;
}

.person-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.person-title {
  color: white;
  font-size: 24px;
  font-weight: bold;
  margin: 0;
}

.dumbbell-btn {
  background: linear-gradient(145deg, #00c073, #00a060);
  border: none;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  font-size: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 8px rgba(255, 127, 39, 0.3);
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.dumbbell-btn:hover {
  background: linear-gradient(145deg, #00a060, #008050);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(255, 127, 39, 0.4);
}

.trainings-section {
  margin-bottom: 30px;
}

.section-title {
  color: #00c073;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 15px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.training-item {
  display: flex;
  align-items: center;
  background-color: #333;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 10px;
  transition: all 0.3s ease;
}

.training-item:hover {
  background-color: #3a3a3a;
  transform: translateY(-1px);
}

.training-icon {
  font-size: 24px;
  margin-right: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.training-details {
  flex: 1;
}

.training-name {
  color: white;
  font-weight: bold;
  font-size: 16px;
  margin-bottom: 4px;
}

.training-duration {
  color: #ccc;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.training-specs {
  margin-top: 6px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.training-spec {
  display: flex;
  align-items: center;
  gap: 4px;
  background-color: #444;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
}

.spec-icon {
  font-size: 14px;
}

.spec-text {
  color: #00c073;
  font-weight: 500;
}

.training-actions {
  display: flex;
  gap: 8px;
}

.delete-btn {
  background: none;
  border: none;
  font-size: 16px;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.delete-btn:hover {
  background-color: #ff4444;
  transform: scale(1.1);
}

.no-trainings {
  color: #888;
  font-style: italic;
  text-align: center;
  padding: 20px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 15px;
}

.metric-card {
  background-color: #333;
  border-radius: 8px;
  padding: 15px;
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.metric-card:hover {
  background-color: #3a3a3a;
  transform: translateY(-2px);
}

.metric-card.goal-achieved {
  background: linear-gradient(
    135deg,
    rgba(34, 197, 94, 0.2),
    rgba(22, 163, 74, 0.3)
  );
  border: 1px solid rgba(34, 197, 94, 0.5);
  backdrop-filter: blur(10px);
  box-shadow: 0 0 20px rgba(34, 197, 94, 0.3);
}

/* Usunięto animację shimmer - była denerwująca */

.metric-label {
  color: #ccc;
  font-size: 12px;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.metric-icon {
  font-size: 18px;
  display: inline-block;
}

.spec-icon {
  font-size: 16px;
  margin-right: 6px;
}

.metric-value {
  color: white;
  font-size: 20px;
  font-weight: bold;
}

.goal-info {
  color: #888;
  font-size: 11px;
  margin-top: 4px;
  font-weight: 500;
}

.metric-card.goal-achieved .goal-info {
  color: rgba(34, 197, 94, 0.8);
  font-weight: 600;
}

.metric-card.goal-not-achieved {
  background: linear-gradient(
    135deg,
    rgba(239, 68, 68, 0.2),
    rgba(220, 38, 38, 0.3)
  );
  border: 1px solid rgba(239, 68, 68, 0.3);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
}

.metric-card.goal-not-achieved .metric-value {
  color: #ef4444;
  font-weight: 700;
}

.metric-card.goal-not-achieved .goal-info {
  color: rgba(239, 68, 68, 0.8);
  font-weight: 600;
}

.supplements-status {
  color: #4caf50;
  font-size: 14px;
  font-weight: bold;
}

.supplements-status.no {
  color: #f44336;
}
</style>
