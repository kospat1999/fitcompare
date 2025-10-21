<template>
  <div class="training-form">
    <h3 class="form-section-title">💪 Dodaj trening</h3>

    <div class="form-group">
      <label class="form-label">Typ treningu</label>
      <div class="dropdown">
        <button class="dropdown-toggle" @click="toggleDropdown" type="button">
          {{ selectedTrainingType }}
          <span>▼</span>
        </button>
        <div v-if="isDropdownOpen" class="dropdown-menu">
          <div
            v-for="type in trainingTypes"
            :key="type"
            class="dropdown-item"
            :class="{ selected: selectedTrainingType === type }"
            @click="selectTrainingType(type)"
          >
            <span v-if="selectedTrainingType === type">✓</span>
            {{ type }}
          </div>
        </div>
      </div>
    </div>

    <!-- Szczegóły treningu siłowni -->
    <div v-if="selectedTrainingType === 'Siłownia'" class="form-group">
      <label class="form-label">Rodzaj treningu</label>
      <div class="dropdown">
        <button
          class="dropdown-toggle"
          @click="toggleGymDropdown"
          type="button"
        >
          {{ selectedGymType }}
          <span>▼</span>
        </button>
        <div v-if="isGymDropdownOpen" class="dropdown-menu">
          <div
            v-for="type in gymTypes"
            :key="type"
            class="dropdown-item"
            :class="{ selected: selectedGymType === type }"
            @click="selectGymType(type)"
          >
            <span v-if="selectedGymType === type">✓</span>
            {{ type }}
          </div>
        </div>
      </div>
    </div>

    <!-- Szczegóły treningu schodów -->
    <div v-if="selectedTrainingType === 'Schody'" class="form-group">
      <label class="form-label">Liczba pięter</label>
      <input
        type="number"
        v-model.number="floors"
        min="1"
        max="100"
        class="number-input-simple"
      />
    </div>

    <div class="form-group">
      <label class="form-label">Czas trwania (min)</label>
      <input
        type="number"
        v-model.number="duration"
        min="1"
        max="300"
        class="number-input-simple"
      />
    </div>

    <button class="action-btn" @click="addTraining">
      <span class="btn-icon">💪</span>
      Dodaj trening
    </button>
  </div>
</template>

<script>
import { ref } from "vue";

export default {
  name: "AddTrainingForm",
  props: {
    personIndex: {
      type: Number,
      required: true,
    },
    selectedDate: {
      type: String,
      required: true,
    },
  },
  emits: ["training-added", "training-added-success"],
  setup(props, { emit }) {
    const trainingTypes = ["Siłownia", "Bieganie", "Schody", "Custom"];
    const selectedTrainingType = ref("Siłownia");
    const duration = ref(60);
    const isDropdownOpen = ref(false);

    // Nowe zmienne dla szczegółów treningów
    const gymTypes = ["Pull", "Push", "FBW", "Lower", "Upper", "Inny"];
    const selectedGymType = ref("Pull");
    const isGymDropdownOpen = ref(false);
    const floors = ref(10);

    const toggleDropdown = () => {
      isDropdownOpen.value = !isDropdownOpen.value;
    };

    const toggleGymDropdown = () => {
      isGymDropdownOpen.value = !isGymDropdownOpen.value;
    };

    const selectTrainingType = (type) => {
      selectedTrainingType.value = type;
      isDropdownOpen.value = false;
    };

    const selectGymType = (type) => {
      selectedGymType.value = type;
      isGymDropdownOpen.value = false;
    };

    const addTraining = () => {
      const training = {
        type: selectedTrainingType.value,
        duration: duration.value,
        details: {},
        date: props.selectedDate,
        timestamp: new Date().toISOString(),
      };

      // Dodaj szczegóły w zależności od typu treningu
      if (selectedTrainingType.value === "Siłownia") {
        training.details.gymType = selectedGymType.value;
      } else if (selectedTrainingType.value === "Schody") {
        training.details.floors = floors.value;
      }

      emit("training-added", props.personIndex, training);

      // Reset form do wartości domyślnych
      duration.value = 60;
      floors.value = 10;
      selectedGymType.value = "Pull";

      // Ukryj formularz
      emit("training-added-success");
    };

    return {
      trainingTypes,
      selectedTrainingType,
      duration,
      isDropdownOpen,
      toggleDropdown,
      selectTrainingType,
      addTraining,
      // Nowe zmienne
      gymTypes,
      selectedGymType,
      isGymDropdownOpen,
      toggleGymDropdown,
      selectGymType,
      floors,
    };
  },
};
</script>

<style scoped>
.training-form {
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

.dropdown {
  position: relative;
}

.dropdown-toggle {
  width: 100%;
  padding: 14px 12px;
  background: linear-gradient(145deg, #1a1a1a, #2a2a2a);
  border: 2px solid #333;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
}

.dropdown-toggle:hover {
  border-color: #555;
  background: linear-gradient(145deg, #2a2a2a, #1a1a1a);
  transform: translateY(-1px);
}

.dropdown-toggle:active {
  transform: translateY(0);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background-color: #1a1a1a;
  border: 1px solid #333;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 1000;
  margin-top: 4px;
}

.dropdown-item {
  padding: 12px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: background-color 0.3s;
}

.dropdown-item:hover {
  background-color: #333;
}

.dropdown-item.selected {
  background-color: #00c073;
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
