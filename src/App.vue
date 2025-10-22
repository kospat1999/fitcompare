<template>
  <div class="app">
    <!-- Login Screen -->
    <LoginForm v-if="!isLoggedIn" @login-success="handleLoginSuccess" />

    <!-- Main App -->
    <div v-else>
      <header class="header">
        <div class="header-left">
          <div class="logo">
            <div class="logo-text">
              <span class="fit">Fit</span><span class="compare">Compare</span>
            </div>
          </div>
        </div>
        <div class="header-center">
          <nav class="nav-tabs">
            <button
              class="nav-tab"
              :class="{ active: activeTab === 'comparison' }"
              @click="activeTab = 'comparison'"
            >
              Porównanie
            </button>
            <button
              class="nav-tab"
              :class="{ active: activeTab === 'add-training' }"
              @click="activeTab = 'add-training'"
            >
              Dodaj trening
            </button>
            <button
              class="nav-tab"
              :class="{ active: activeTab === 'add-daily-data' }"
              @click="handleDailyDataTabClick"
            >
              Uzupełnij dane
            </button>
            <button
              class="nav-tab"
              :class="{ active: activeTab === 'goals' }"
              @click="activeTab = 'goals'"
            >
              Cele
            </button>
          </nav>
        </div>
        <div class="header-right">
          <div class="user-details">
            <span class="user-name">{{ currentUser.name }}</span>
            <span class="challenge-counter">
              {{ daysUntilChallengeEnd }} dni do końca wyzwania
            </span>
          </div>
          <button class="logout-btn" @click="logout">Wyloguj</button>
        </div>
      </header>

      <main class="main-content">
        <!-- Comparison View -->
        <div v-if="activeTab === 'comparison'" class="comparison-container">
          <div class="calendar-section">
            <h3 class="calendar-title">Kalendarz aktywności</h3>
            <div class="calendar-controls">
              <button
                class="calendar-btn prev"
                @click="goToPreviousWeek"
                title="Poprzedni tydzień"
              ></button>
              <h4 class="current-month">{{ currentWeekRange }}</h4>
              <button
                class="calendar-btn next"
                @click="goToNextWeek"
                title="Następny tydzień"
              ></button>
            </div>
            <div class="calendar-horizontal">
              <div class="calendar-week">
                <div
                  v-for="day in currentWeekDays"
                  :key="day.date"
                  class="calendar-day-small"
                  :class="{
                    'other-month': !day.isCurrentMonth,
                    today: day.isToday,
                    'has-data-fiko': day.hasDataFiko,
                    'has-data-patka': day.hasDataPatka,
                    'has-data-both': day.hasDataBoth,
                    selected: day.date === selectedComparisonDate,
                  }"
                  @click="selectComparisonDate(day.date)"
                >
                  <div class="day-name">{{ day.dayName }}</div>
                  <div class="day-number">{{ day.dayNumber }}</div>
                  <div class="day-indicators-small">
                    <div
                      v-if="day.hasDataFiko"
                      class="indicator-small fiko"
                    ></div>
                    <div
                      v-if="day.hasDataPatka"
                      class="indicator-small patka"
                    ></div>
                  </div>
                </div>
              </div>
            </div>
            <div class="selected-date-info">
              <p>
                Wybrany dzień: <strong>{{ formatComparisonDate }}</strong>
              </p>
            </div>
          </div>

          <div class="comparison-panels">
            <PersonPanel
              :person="persons[0]"
              :person-index="0"
              :selected-date="selectedComparisonDate"
              :goals="persons[0].goals"
              @update-person="updatePerson"
              @remove-training="removeTraining"
            />
            <PersonPanel
              :person="persons[1]"
              :person-index="1"
              :selected-date="selectedComparisonDate"
              :goals="persons[1].goals"
              @update-person="updatePerson"
              @remove-training="removeTraining"
            />
          </div>

          <!-- Weekly Averages Summary -->
          <div class="weekly-averages-summary">
            <h3 class="summary-title">📈 Średnie z ostatniego tygodnia</h3>
            <div class="summary-cards">
              <div class="summary-card" v-if="fikoWeeklyAverages.daysCount > 0">
                <div class="summary-header">
                  <img
                    :src="persons[0].avatar"
                    :alt="persons[0].name"
                    class="summary-avatar"
                  />
                  <h4>{{ persons[0].name }}</h4>
                </div>
                <div class="summary-stats">
                  <div class="stat-item">
                    <span class="label">Kroki:</span>
                    <span class="value">{{
                      fikoWeeklyAverages.steps.toLocaleString()
                    }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="label">Kalorie:</span>
                    <span class="value">{{
                      fikoWeeklyAverages.calories.toLocaleString()
                    }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="label">Białko:</span>
                    <span class="value">{{ fikoWeeklyAverages.protein }}g</span>
                  </div>
                </div>
              </div>
              <div
                class="summary-card"
                v-if="patkaWeeklyAverages.daysCount > 0"
              >
                <div class="summary-header">
                  <img
                    :src="persons[1].avatar"
                    :alt="persons[1].name"
                    class="summary-avatar"
                  />
                  <h4>{{ persons[1].name }}</h4>
                </div>
                <div class="summary-stats">
                  <div class="stat-item">
                    <span class="label">Kroki:</span>
                    <span class="value">{{
                      patkaWeeklyAverages.steps.toLocaleString()
                    }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="label">Kalorie:</span>
                    <span class="value">{{
                      patkaWeeklyAverages.calories.toLocaleString()
                    }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="label">Białko:</span>
                    <span class="value"
                      >{{ patkaWeeklyAverages.protein }}g</span
                    >
                  </div>
                </div>
              </div>
              <div
                class="no-data-message"
                v-if="
                  fikoWeeklyAverages.daysCount === 0 &&
                  patkaWeeklyAverages.daysCount === 0
                "
              >
                <p>
                  📝 Brak danych z ostatniego tygodnia. Dodaj dane w sekcji
                  "Uzupełnij dane" aby zobaczyć średnie.
                </p>
              </div>
            </div>
          </div>

          <!-- Weight Loss Summary -->
          <div class="weight-loss-summary">
            <h3 class="summary-title">📊 Podsumowanie utraty wagi</h3>
            <div class="summary-cards">
              <div class="summary-card" v-if="fikoWeightLoss.hasData">
                <div class="summary-header">
                  <img
                    :src="persons[0].avatar"
                    :alt="persons[0].name"
                    class="summary-avatar"
                  />
                  <h4>{{ persons[0].name }}</h4>
                </div>
                <div class="summary-stats">
                  <div class="weight-stat">
                    <span class="label">Początkowa waga:</span>
                    <span class="value"
                      >{{ fikoWeightLoss.firstWeight }}kg</span
                    >
                  </div>
                  <div class="weight-stat">
                    <span class="label">Aktualna waga:</span>
                    <span class="value">{{ fikoWeightLoss.lastWeight }}kg</span>
                  </div>
                  <div
                    class="weight-stat loss"
                    :class="{
                      positive: fikoWeightLoss.loss > 0,
                      negative: fikoWeightLoss.loss < 0,
                    }"
                  >
                    <span class="label">Zmiana:</span>
                    <span class="value"
                      >{{ fikoWeightLoss.loss > 0 ? "+" : ""
                      }}{{ fikoWeightLoss.loss.toFixed(1) }}kg</span
                    >
                  </div>
                  <div class="entries-count">
                    <span class="label">Pomiary:</span>
                    <span class="value">{{ fikoWeightLoss.entriesCount }}</span>
                  </div>

                  <!-- Informacje o celu -->
                  <div v-if="fikoWeightLoss.hasGoal" class="goal-info">
                    <div class="weight-stat">
                      <span class="label">Waga docelowa:</span>
                      <span class="value"
                        >{{ fikoWeightLoss.targetWeight }}kg</span
                      >
                    </div>
                    <div
                      class="weight-stat"
                      :class="{
                        positive: fikoWeightLoss.weightToGoal > 0,
                        negative: fikoWeightLoss.weightToGoal < 0,
                      }"
                    >
                      <span class="label">Do celu:</span>
                      <span class="value"
                        >{{ fikoWeightLoss.weightToGoal > 0 ? "+" : ""
                        }}{{ fikoWeightLoss.weightToGoal.toFixed(1) }}kg</span
                      >
                    </div>
                    <div
                      v-if="fikoWeightLoss.dailyDeficit > 0"
                      class="weight-stat highlight"
                    >
                      <span class="label">Dzienny deficyt:</span>
                      <span class="value"
                        >{{ fikoWeightLoss.dailyDeficit }} kcal</span
                      >
                    </div>
                  </div>
                </div>
              </div>
              <div class="summary-card" v-if="patkaWeightLoss.hasData">
                <div class="summary-header">
                  <img
                    :src="persons[1].avatar"
                    :alt="persons[1].name"
                    class="summary-avatar"
                  />
                  <h4>{{ persons[1].name }}</h4>
                </div>
                <div class="summary-stats">
                  <div class="weight-stat">
                    <span class="label">Początkowa waga:</span>
                    <span class="value"
                      >{{ patkaWeightLoss.firstWeight }}kg</span
                    >
                  </div>
                  <div class="weight-stat">
                    <span class="label">Aktualna waga:</span>
                    <span class="value"
                      >{{ patkaWeightLoss.lastWeight }}kg</span
                    >
                  </div>
                  <div
                    class="weight-stat loss"
                    :class="{
                      positive: patkaWeightLoss.loss > 0,
                      negative: patkaWeightLoss.loss < 0,
                    }"
                  >
                    <span class="label">Zmiana:</span>
                    <span class="value"
                      >{{ patkaWeightLoss.loss > 0 ? "+" : ""
                      }}{{ patkaWeightLoss.loss.toFixed(1) }}kg</span
                    >
                  </div>
                  <div class="entries-count">
                    <span class="label">Pomiary:</span>
                    <span class="value">{{
                      patkaWeightLoss.entriesCount
                    }}</span>
                  </div>

                  <!-- Informacje o celu -->
                  <div v-if="patkaWeightLoss.hasGoal" class="goal-info">
                    <div class="weight-stat">
                      <span class="label">Waga docelowa:</span>
                      <span class="value"
                        >{{ patkaWeightLoss.targetWeight }}kg</span
                      >
                    </div>
                    <div
                      class="weight-stat"
                      :class="{
                        positive: patkaWeightLoss.weightToGoal > 0,
                        negative: patkaWeightLoss.weightToGoal < 0,
                      }"
                    >
                      <span class="label">Do celu:</span>
                      <span class="value"
                        >{{ patkaWeightLoss.weightToGoal > 0 ? "+" : ""
                        }}{{ patkaWeightLoss.weightToGoal.toFixed(1) }}kg</span
                      >
                    </div>
                    <div
                      v-if="patkaWeightLoss.dailyDeficit > 0"
                      class="weight-stat highlight"
                    >
                      <span class="label">Dzienny deficyt:</span>
                      <span class="value"
                        >{{ patkaWeightLoss.dailyDeficit }} kcal</span
                      >
                    </div>
                  </div>
                </div>
              </div>
              <div
                class="no-data-message"
                v-if="!fikoWeightLoss.hasData && !patkaWeightLoss.hasData"
              >
                <p>
                  📝 Brak danych o wadze. Dodaj pomiary wagi w sekcji "Uzupełnij
                  dane" aby zobaczyć podsumowanie.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Add Training View -->
        <div v-if="activeTab === 'add-training'" class="add-data-container">
          <h2 class="add-data-title">
            Dodaj trening dla {{ currentUser.name }}
          </h2>

          <div class="user-info-card">
            <div class="user-avatar">
              <img
                :src="getCurrentUserAvatar()"
                :alt="currentUser.name"
                class="avatar-image"
              />
            </div>
            <div class="user-details">
              <h3 class="user-name">{{ currentUser.name }}</h3>
              <p class="user-description">Dodaj nowy trening</p>
            </div>
          </div>

          <div class="date-selector-section">
            <h3 class="section-title">Wybrany dzień z kalendarza</h3>
            <div class="date-display">
              <p class="date-info">
                Dodajesz trening dla:
                <strong>{{ formatComparisonDate }}</strong>
              </p>
              <p class="date-note">
                Aby zmienić dzień, użyj kalendarza w zakładce "Porównanie"
              </p>
            </div>
          </div>

          <AddTrainingForm
            :person-index="getCurrentUserPersonIndex()"
            :selected-date="selectedComparisonDate"
            @training-added="addTraining"
            @training-added-success="handleTrainingAddedSuccess"
          />
        </div>

        <!-- Add Daily Data View -->
        <div v-if="activeTab === 'add-daily-data'" class="add-data-container">
          <h2 class="add-data-title">
            Uzupełnij dane dla {{ currentUser.name }}
          </h2>

          <div class="user-info-card">
            <div class="user-avatar">
              <img
                :src="getCurrentUserAvatar()"
                :alt="currentUser.name"
                class="avatar-image"
              />
            </div>
            <div class="user-details">
              <h3 class="user-name">{{ currentUser.name }}</h3>
              <p class="user-description">Uzupełnij statystyki dzienne</p>
            </div>
          </div>

          <div class="date-selector-section">
            <h3 class="section-title">Wybrany dzień z kalendarza</h3>
            <div class="date-display">
              <p class="date-info">
                Uzupełniasz dane dla:
                <strong>{{ formatComparisonDate }}</strong>
              </p>
              <p class="date-note">
                Aby zmienić dzień, użyj kalendarza w zakładce "Porównanie"
              </p>
            </div>
          </div>

          <DailyDataForm
            ref="dailyDataFormRef"
            :selected-date="selectedComparisonDate"
            :person-data="persons[getCurrentUserPersonIndex()]"
            @daily-stats-saved="handleDailyStatsSaved"
          />
        </div>

        <!-- Goals Form -->
        <div v-if="activeTab === 'goals'" class="goals-container">
          <GoalsForm
            :user-id="currentUser.id"
            :person-data="persons[getCurrentUserPersonIndex()]"
            @goals-saved="handleGoalsSaved"
          />
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, computed, watch, nextTick } from "vue";
import PersonPanel from "./components/PersonPanel.vue";
import AddTrainingForm from "./components/AddTrainingForm.vue";
import DailyDataForm from "./components/DailyDataForm.vue";
import GoalsForm from "./components/GoalsForm.vue";
import LoginForm from "./components/LoginForm.vue";
import { supabase } from "./supabase.js";

export default {
  name: "App",
  components: {
    PersonPanel,
    AddTrainingForm,
    DailyDataForm,
    GoalsForm,
    LoginForm,
  },
  setup() {
    const activeTab = ref("comparison");
    const isLoggedIn = ref(false);
    const currentUser = ref(null);
    const dailyDataFormRef = ref(null);

    const persons = ref([
      {
        name: "Fiko",
        avatar: "/dogfiko.jpeg", // Zdjęcie golden retrievera
        trainings: [],
        metrics: {
          trainingTime: 0,
          distance: 0.0,
          calories: 0,
          steps: 0,
          protein: 0,
          supplements: false,
        },
        dailyStats: [],
        goals: {
          training_time_goal: 60,
          calories_goal: 2000,
          steps_goal: 10000,
          protein_goal: 100.0,
          target_weight: null,
        },
      },
      {
        name: "Patka",
        avatar: "/dogpatka.jpg", // Zdjęcie beagle
        trainings: [],
        metrics: {
          trainingTime: 0,
          distance: 0.0,
          calories: 0,
          steps: 0,
          protein: 0,
          supplements: false,
        },
        dailyStats: [],
        goals: {
          training_time_goal: 60,
          calories_goal: 2000,
          steps_goal: 10000,
          protein_goal: 100.0,
          target_weight: null,
        },
      },
    ]);

    const dailyStats = reactive({
      calories: 0,
      steps: 0,
      protein: 0,
      weight: null,
      supplements: false,
    });

    // Date selector logic - użyj lokalnej strefy czasowej
    const getTodayString = () => {
      const today = new Date();
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, "0");
      const day = String(today.getDate()).padStart(2, "0");
      return `${year}-${month}-${day}`;
    };

    const today = ref(getTodayString());
    const selectedDate = ref(getTodayString());

    // Calendar logic
    const currentMonth = ref(new Date().getMonth());
    const currentYear = ref(new Date().getFullYear());
    const selectedComparisonDate = ref(getTodayString());

    const weekDays = ["Pon", "Wto", "Śro", "Czw", "Pią", "Sob", "Nie"];

    const currentWeekRange = computed(() => {
      if (currentWeekDays.value.length === 0) return "";

      const firstDay = currentWeekDays.value[0];
      const lastDay = currentWeekDays.value[currentWeekDays.value.length - 1];

      const firstDate = new Date(firstDay.date);
      const lastDate = new Date(lastDay.date);

      const monthNames = [
        "Sty",
        "Lut",
        "Mar",
        "Kwi",
        "Maj",
        "Cze",
        "Lip",
        "Sie",
        "Wrz",
        "Paź",
        "Lis",
        "Gru",
      ];

      const firstMonth = monthNames[firstDate.getMonth()];
      const lastMonth = monthNames[lastDate.getMonth()];
      const firstDayNum = firstDate.getDate();
      const lastDayNum = lastDate.getDate();

      if (firstDate.getMonth() === lastDate.getMonth()) {
        return `${firstDayNum}-${lastDayNum} ${firstMonth} ${firstDate.getFullYear()}`;
      } else {
        return `${firstDayNum} ${firstMonth} - ${lastDayNum} ${lastMonth} ${firstDate.getFullYear()}`;
      }
    });

    const formatComparisonDate = computed(() => {
      const date = new Date(selectedComparisonDate.value);
      return date.toLocaleDateString("pl-PL", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
    });

    const getWeightLossSummary = (personIndex) => {
      const person = persons.value[personIndex];
      if (!person.dailyStats || person.dailyStats.length === 0) {
        return {
          firstWeight: null,
          lastWeight: null,
          loss: 0,
          hasData: false,
          targetWeight: null,
          weightToGoal: 0,
          dailyDeficit: 0,
          hasGoal: false,
        };
      }

      // Filtruj tylko wpisy z wagą
      const weightEntries = person.dailyStats.filter(
        (stat) => stat.weight !== null && stat.weight !== undefined
      );

      if (weightEntries.length === 0) {
        return {
          firstWeight: null,
          lastWeight: null,
          loss: 0,
          hasData: false,
          targetWeight: null,
          weightToGoal: 0,
          dailyDeficit: 0,
          hasGoal: false,
        };
      }

      // Sortuj po dacie
      const sortedEntries = weightEntries.sort(
        (a, b) => new Date(a.date) - new Date(b.date)
      );

      const firstWeight = sortedEntries[0].weight;
      const lastWeight = sortedEntries[sortedEntries.length - 1].weight;
      const loss = firstWeight - lastWeight;

      // Oblicz cele i deficyt
      const targetWeight = person.goals?.target_weight || null;
      const weightToGoal = targetWeight ? lastWeight - targetWeight : 0;

      // Oblicz dni do końca wyzwania
      const today = new Date();
      const challengeEnd = new Date("2026-01-31");
      const timeDiff = challengeEnd.getTime() - today.getTime();
      const daysRemaining = Math.max(
        0,
        Math.ceil(timeDiff / (1000 * 3600 * 24))
      );

      // Oblicz dzienny deficyt (1kg = 7000 kcal)
      const dailyDeficit =
        weightToGoal > 0 && daysRemaining > 0
          ? Math.round((weightToGoal * 7000) / daysRemaining)
          : 0;

      return {
        firstWeight,
        lastWeight,
        loss,
        hasData: true,
        entriesCount: sortedEntries.length,
        targetWeight,
        weightToGoal,
        dailyDeficit,
        hasGoal: targetWeight !== null,
      };
    };

    const fikoWeightLoss = computed(() => getWeightLossSummary(0));
    const patkaWeightLoss = computed(() => getWeightLossSummary(1));

    // Funkcja do obliczania średnich z ostatniego tygodnia
    const getWeeklyAverages = (personIndex) => {
      const person = persons.value[personIndex];
      if (!person.dailyStats || person.dailyStats.length === 0) {
        return { steps: 0, calories: 0, protein: 0, daysCount: 0 };
      }

      const today = new Date();
      const weekAgo = new Date(today);
      weekAgo.setDate(today.getDate() - 7);

      // Filtruj dane z ostatniego tygodnia
      const weeklyStats = person.dailyStats.filter((stat) => {
        const statDate = new Date(stat.date);
        return statDate >= weekAgo && statDate <= today;
      });

      if (weeklyStats.length === 0) {
        return { steps: 0, calories: 0, protein: 0, daysCount: 0 };
      }

      // Oblicz średnie tylko z dni, które mają dane
      const validStats = weeklyStats.filter(
        (stat) => stat.steps > 0 || stat.calories > 0 || stat.protein > 0
      );

      if (validStats.length === 0) {
        return { steps: 0, calories: 0, protein: 0, daysCount: 0 };
      }

      const totalSteps = validStats.reduce(
        (sum, stat) => sum + (stat.steps || 0),
        0
      );
      const totalCalories = validStats.reduce(
        (sum, stat) => sum + (stat.calories || 0),
        0
      );
      const totalProtein = validStats.reduce(
        (sum, stat) => sum + (stat.protein || 0),
        0
      );

      return {
        steps: Math.round(totalSteps / validStats.length),
        calories: Math.round(totalCalories / validStats.length),
        protein: Math.round(totalProtein / validStats.length),
        daysCount: validStats.length,
      };
    };

    const fikoWeeklyAverages = computed(() => getWeeklyAverages(0));
    const patkaWeeklyAverages = computed(() => getWeeklyAverages(1));

    const currentWeekDays = computed(() => {
      const days = [];
      const selectedDateObj = new Date(selectedComparisonDate.value);
      const dayOfWeek = selectedDateObj.getDay();
      const mondayOffset = (dayOfWeek + 6) % 7; // Convert to Monday = 0

      // Get Monday of the current week
      const monday = new Date(selectedDateObj);
      monday.setDate(selectedDateObj.getDate() - mondayOffset);

      // Generate 7 days starting from Monday
      for (let i = 0; i < 7; i++) {
        const date = new Date(monday);
        date.setDate(monday.getDate() + i);
        const dateString = date.toISOString().split("T")[0];
        const isToday = dateString === today.value;
        const isCurrentMonth = date.getMonth() === currentMonth.value;

        const dayNames = ["Pon", "Wto", "Śro", "Czw", "Pią", "Sob", "Nie"];

        days.push({
          date: dateString,
          dayNumber: date.getDate(),
          dayName: dayNames[i],
          isCurrentMonth,
          isToday,
          hasDataFiko: checkIfDateHasData(0, dateString),
          hasDataPatka: checkIfDateHasData(1, dateString),
          hasDataBoth:
            checkIfDateHasData(0, dateString) &&
            checkIfDateHasData(1, dateString),
        });
      }

      return days;
    });

    const checkIfDateHasData = (personIndex, date) => {
      const person = persons.value[personIndex];
      if (!person.dailyStats) return false;

      // Check daily stats
      const hasDailyStats = person.dailyStats.some(
        (stat) => stat.date === date
      );

      // Check trainings
      const hasTrainings = person.trainings.some(
        (training) => training.date === date
      );

      return hasDailyStats || hasTrainings;
    };

    const selectComparisonDate = (date) => {
      selectedComparisonDate.value = date;
    };

    const goToPreviousWeek = () => {
      const currentDate = new Date(selectedComparisonDate.value);
      currentDate.setDate(currentDate.getDate() - 7);
      selectedComparisonDate.value = currentDate.toISOString().split("T")[0];
    };

    const goToNextWeek = () => {
      const currentDate = new Date(selectedComparisonDate.value);
      currentDate.setDate(currentDate.getDate() + 7);
      selectedComparisonDate.value = currentDate.toISOString().split("T")[0];
    };

    const formatSelectedDate = computed(() => {
      const date = new Date(selectedDate.value);
      return date.toLocaleDateString("pl-PL", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
    });

    const daysUntilChallengeEnd = computed(() => {
      const today = new Date();
      const challengeEnd = new Date(2026, 0, 31); // 31 stycznia 2026

      // Ustaw czas na początek dnia dla obu dat
      today.setHours(0, 0, 0, 0);
      challengeEnd.setHours(0, 0, 0, 0);

      const timeDiff = challengeEnd.getTime() - today.getTime();
      const daysDiff = Math.floor(timeDiff / (1000 * 3600 * 24));

      // Jeśli wyzwanie już się skończyło, pokaż 0
      if (daysDiff < 0) {
        return 0;
      }

      return daysDiff;
    });

    const setToday = () => {
      const todayString = getTodayString();
      selectedDate.value = todayString;
    };

    const setYesterday = () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const year = yesterday.getFullYear();
      const month = String(yesterday.getMonth() + 1).padStart(2, "0");
      const day = String(yesterday.getDate()).padStart(2, "0");
      selectedDate.value = `${year}-${month}-${day}`;
    };

    const loadDailyStatsForDate = (date) => {
      const personIndex = getCurrentUserPersonIndex();
      const person = persons.value[personIndex];

      if (person.dailyStats) {
        const statsForDate = person.dailyStats.find(
          (stat) => stat.date === date
        );
        if (statsForDate) {
          Object.assign(dailyStats, {
            calories: statsForDate.calories || 0,
            steps: statsForDate.steps || 0,
            protein: statsForDate.protein || 0,
            weight:
              statsForDate.weight !== undefined ? statsForDate.weight : null,
            supplements: statsForDate.supplements || false,
          });
        } else {
          // Reset to default values if no stats for this date
          Object.assign(dailyStats, {
            calories: 0,
            steps: 0,
            protein: 0,
            weight: null,
            supplements: false,
          });
        }
      }
    };

    // Watch for date changes
    watch(selectedDate, (newDate) => {
      loadDailyStatsForDate(newDate);
    });

    const handleLoginSuccess = (user) => {
      currentUser.value = user;
      isLoggedIn.value = true;

      // Dodaj test dane dla debugowania
      const personIndex = getCurrentUserPersonIndex();
      if (persons.value[personIndex]) {
        persons.value[personIndex].dailyStats = [
          {
            date: "2024-10-20",
            calories: 1500,
            steps: 8000,
            protein: 80,
            weight: 70,
            supplements: true,
            timestamp: new Date().toISOString(),
          },
        ];
        console.log(
          "Added test data for debugging:",
          persons.value[personIndex].dailyStats
        );
      }

      loadDataFromSupabase();
    };

    const logout = () => {
      localStorage.removeItem("fitcompare-user");
      localStorage.removeItem("fitcompare-data");
      currentUser.value = null;
      isLoggedIn.value = false;
    };

    const updatePerson = async (personIndex, updatedPerson) => {
      persons.value[personIndex] = {
        ...persons.value[personIndex],
        ...updatedPerson,
      };
      await saveToSupabase();
    };

    const addTraining = async (personIndex, training) => {
      // Training już ma date i timestamp z AddTrainingForm
      persons.value[personIndex].trainings.push(training);
      // Update training time metric
      persons.value[personIndex].metrics.trainingTime = persons.value[
        personIndex
      ].trainings.reduce((total, t) => total + t.duration, 0);
      await saveToSupabase();
    };

    const handleGoalsSaved = async (goalsData) => {
      const personIndex = getCurrentUserPersonIndex();
      const person = persons.value[personIndex];

      // Update person's goals
      person.goals = { ...goalsData };

      await saveToSupabase();

      // Przekieruj na porównanie żeby zobaczyć zmiany
      activeTab.value = "comparison";
    };

    const handleTrainingAddedSuccess = () => {
      // Przekieruj na stronę porównania
      activeTab.value = "comparison";
    };

    const handleDailyDataTabClick = () => {
      activeTab.value = "add-daily-data";
      // DailyDataForm sam załaduje dane przez watch na selectedDate
    };

    const removeTraining = async (personIndex, trainingIndex) => {
      const person = persons.value[personIndex];
      const trainingToRemove = person.trainings[trainingIndex];

      // Usuń trening z lokalnej tablicy
      person.trainings.splice(trainingIndex, 1);

      // Update training time metric
      person.metrics.trainingTime = person.trainings.reduce(
        (total, t) => total + t.duration,
        0
      );

      // Usuń trening z bazy danych
      await removeTrainingFromSupabase(person.name, trainingToRemove);

      await saveToSupabase();
    };

    const removeTrainingFromSupabase = async (personName, trainingToRemove) => {
      try {
        const userId = personName === "Fiko" ? "fiko" : "patka";

        // Znajdź user_id
        const { data: userData } = await supabase
          .from("users")
          .select("id")
          .eq("username", userId)
          .single();

        if (userData) {
          // Usuń trening z bazy danych
          const { error } = await supabase
            .from("trainings")
            .delete()
            .eq("user_id", userData.id)
            .eq("type", trainingToRemove.type)
            .eq("duration", trainingToRemove.duration)
            .eq("date", trainingToRemove.date);

          if (error) {
            console.error("Error removing training from Supabase:", error);
          } else {
            console.log("Training removed from Supabase successfully");
          }
        }
      } catch (error) {
        console.error("Error in removeTrainingFromSupabase:", error);
      }
    };

    const getCurrentUserPersonIndex = () => {
      if (!currentUser.value) {
        console.log("No current user");
        return 0;
      }
      const index = currentUser.value.name === "Fiko" ? 0 : 1;
      console.log("Current user:", currentUser.value.name, "Index:", index);
      return index;
    };

    const getCurrentUserAvatar = () => {
      if (!currentUser.value) return "/dogpatka.jpg"; // Domyślny avatar
      return currentUser.value.name === "Fiko"
        ? "/dogfiko.jpeg"
        : "/dogpatka.jpg";
    };

    const handleDailyStatsSaved = async (statsData) => {
      console.log("=== SAVING DAILY STATS ===");
      console.log("Stats data:", statsData);
      console.log("Selected date:", selectedComparisonDate.value);

      const personIndex = getCurrentUserPersonIndex();
      const person = persons.value[personIndex];
      console.log("Person index:", personIndex);
      console.log("Person:", person);

      // Add date to the stats
      const statsWithDate = {
        ...statsData,
        date: selectedComparisonDate.value,
        timestamp: new Date().toISOString(),
      };
      console.log("Stats with date:", statsWithDate);

      // Store daily stats with date
      if (!person.dailyStats) {
        person.dailyStats = [];
      }

      // Check if stats for this date already exist
      const existingStatsIndex = person.dailyStats.findIndex(
        (stat) => stat.date === selectedComparisonDate.value
      );
      console.log("Existing stats index:", existingStatsIndex);

      if (existingStatsIndex !== -1) {
        // Update existing stats
        person.dailyStats[existingStatsIndex] = statsWithDate;
        console.log("Updated existing stats");
      } else {
        // Add new stats
        person.dailyStats.push(statsWithDate);
        console.log("Added new stats");
      }

      console.log("Final dailyStats:", person.dailyStats);

      // Update total metrics (only add new values, don't accumulate)
      const previousStats =
        existingStatsIndex !== -1
          ? person.dailyStats[existingStatsIndex]
          : null;
      if (previousStats) {
        // Subtract previous values and add new ones
        person.metrics.calories =
          person.metrics.calories -
          (previousStats.calories || 0) +
          statsData.calories;
        person.metrics.steps =
          person.metrics.steps - (previousStats.steps || 0) + statsData.steps;
        person.metrics.protein =
          person.metrics.protein -
          (previousStats.protein || 0) +
          statsData.protein;
      } else {
        // Add new values
        person.metrics.calories += statsData.calories;
        person.metrics.steps += statsData.steps;
        person.metrics.protein += statsData.protein;
      }

      person.metrics.supplements = statsData.supplements;

      await saveToSupabase();

      // Przekieruj na porównanie żeby zobaczyć zmiany
      activeTab.value = "comparison";
      console.log("=== END SAVING DAILY STATS ===");
    };

    const loadStatsForDate = (date) => {
      console.log("=== LOAD STATS FOR DATE ===");
      console.log("Loading stats for date:", date);
      console.log("Current user:", currentUser.value?.name);
      console.log("Persons data:", persons.value);

      if (!dailyDataFormRef.value) {
        console.log("❌ dailyDataFormRef not available");
        return;
      }

      const personIndex = getCurrentUserPersonIndex();
      console.log("Person index:", personIndex);

      if (personIndex === -1 || !persons.value[personIndex]) {
        console.log("❌ Person not found");
        return;
      }

      const person = persons.value[personIndex];
      console.log("✅ Person data:", person);
      console.log("✅ Person dailyStats:", person.dailyStats);
      console.log("✅ Person dailyStats length:", person.dailyStats?.length);

      // Znajdź dane dla tego dnia
      const statsForDate = person.dailyStats?.find(
        (stat) => stat.date === date
      );

      console.log("🔍 Found stats for date:", statsForDate);
      console.log(
        "🔍 All dailyStats dates:",
        person.dailyStats?.map((s) => s.date)
      );

      // Ustaw dane w formularzu
      if (dailyDataFormRef.value && dailyDataFormRef.value.setStatsData) {
        console.log("✅ Calling setStatsData with:", statsForDate);
        dailyDataFormRef.value.setStatsData(statsForDate);
        console.log("✅ setStatsData called successfully");
      } else {
        console.log("❌ setStatsData method not available");
        console.log("dailyDataFormRef.value:", dailyDataFormRef.value);
      }
      console.log("=== END LOAD STATS ===");
    };

    const increment = (field) => {
      dailyStats[field] += field === "weight" || field === "protein" ? 0.1 : 1;
    };

    const decrement = (field) => {
      if (dailyStats[field] > 0) {
        dailyStats[field] -=
          field === "weight" || field === "protein" ? 0.1 : 1;
      }
    };

    const saveToSupabase = async () => {
      try {
        console.log("Saving to Supabase for user:", currentUser.value?.name);
        console.log("Persons data:", persons.value);

        // Zapisz treningi i dane dzienne dla każdej osoby
        for (const person of persons.value) {
          const userId = person.name === "Fiko" ? "fiko" : "patka";

          // Znajdź user_id
          const { data: userData } = await supabase
            .from("users")
            .select("id")
            .eq("username", userId)
            .single();

          if (userData) {
            // Zapisz treningi
            if (person.trainings && person.trainings.length > 0) {
              for (const training of person.trainings) {
                // Sprawdź czy trening już istnieje
                const { data: existingTraining } = await supabase
                  .from("trainings")
                  .select("id")
                  .eq("user_id", userData.id)
                  .eq("type", training.type)
                  .eq("duration", training.duration)
                  .eq("date", training.date)
                  .single();

                if (existingTraining) {
                  // Aktualizuj istniejący trening
                  const { error: trainingError } = await supabase
                    .from("trainings")
                    .update({
                      details: training.details || {},
                      timestamp: training.timestamp,
                      updated_at: new Date().toISOString(),
                    })
                    .eq("id", existingTraining.id);

                  if (trainingError)
                    console.error("Training update error:", trainingError);
                } else {
                  // Dodaj nowy trening
                  const { error: trainingError } = await supabase
                    .from("trainings")
                    .insert({
                      user_id: userData.id,
                      type: training.type,
                      duration: training.duration,
                      details: training.details || {},
                      date: training.date,
                      timestamp: training.timestamp,
                    });

                  if (trainingError)
                    console.error("Training insert error:", trainingError);
                }
              }
            }

            // Zapisz dane dzienne
            if (person.dailyStats && person.dailyStats.length > 0) {
              for (const dailyStat of person.dailyStats) {
                const { error: dailyError } = await supabase
                  .from("daily_stats")
                  .upsert(
                    {
                      user_id: userData.id,
                      date: dailyStat.date,
                      calories: dailyStat.calories || 0,
                      steps: dailyStat.steps || 0,
                      protein: dailyStat.protein || 0,
                      weight:
                        dailyStat.weight !== undefined
                          ? dailyStat.weight
                          : null,
                      supplements: dailyStat.supplements || false,
                      timestamp: dailyStat.timestamp,
                    },
                    {
                      onConflict: "user_id,date",
                      ignoreDuplicates: false,
                    }
                  );

                if (dailyError)
                  console.error("Daily stats save error:", dailyError);
              }
            }

            // Zapisz metryki
            const { error: metricsError } = await supabase
              .from("user_metrics")
              .upsert(
                {
                  user_id: userData.id,
                  training_time: person.metrics.trainingTime || 0,
                  distance: person.metrics.distance || 0,
                  calories: person.metrics.calories || 0,
                  steps: person.metrics.steps || 0,
                  protein: person.metrics.protein || 0,
                  supplements: person.metrics.supplements || false,
                },
                {
                  onConflict: "user_id",
                  ignoreDuplicates: false,
                }
              );

            if (metricsError)
              console.error("Metrics save error:", metricsError);

            // Zapisz cele
            if (person.goals) {
              const { error: goalsError } = await supabase
                .from("user_goals")
                .upsert(
                  {
                    user_id: userData.id,
                    training_time_goal: person.goals.training_time_goal || 60,
                    calories_goal: person.goals.calories_goal || 2000,
                    steps_goal: person.goals.steps_goal || 10000,
                    protein_goal: person.goals.protein_goal || 100.0,
                    supplements_goal: true, // Zawsze true
                  },
                  {
                    onConflict: "user_id",
                    ignoreDuplicates: false,
                  }
                );

              if (goalsError) console.error("Goals save error:", goalsError);
            }
          }
        }

        console.log("Successfully saved to Supabase!");
      } catch (err) {
        console.error("Error saving to Supabase:", err);
        // Fallback to localStorage
        localStorage.setItem("fitcompare-data", JSON.stringify(persons.value));
      }
    };

    const loadDataFromSupabase = async () => {
      try {
        console.log(
          "Loading data from Supabase for user:",
          currentUser.value?.name
        );

        // Załaduj dane dla obu użytkowników
        const loadedPersons = [];

        for (const username of ["fiko", "patka"]) {
          // Znajdź user_id
          const { data: userData } = await supabase
            .from("users")
            .select("id")
            .eq("username", username)
            .single();

          if (userData) {
            // Załaduj treningi
            const { data: trainings } = await supabase
              .from("trainings")
              .select("*")
              .eq("user_id", userData.id)
              .order("date", { ascending: false });

            // Załaduj dane dzienne
            const { data: dailyStats } = await supabase
              .from("daily_stats")
              .select("*")
              .eq("user_id", userData.id)
              .order("date", { ascending: false });

            console.log(`📊 Daily stats for ${username}:`, dailyStats);

            // Załaduj metryki
            const { data: metrics } = await supabase
              .from("user_metrics")
              .select("*")
              .eq("user_id", userData.id)
              .single();

            // Załaduj cele
            const { data: goals } = await supabase
              .from("user_goals")
              .select("*")
              .eq("user_id", userData.id)
              .single();

            loadedPersons.push({
              name: username === "fiko" ? "Fiko" : "Patka",
              avatar: username === "fiko" ? "/dogfiko.jpeg" : "/dogpatka.jpg", // Dodaj ścieżki do obrazów
              trainings: trainings || [],
              dailyStats: dailyStats || [],
              metrics: metrics
                ? {
                    trainingTime: metrics.training_time || 0,
                    distance: metrics.distance || 0,
                    calories: metrics.calories || 0,
                    steps: metrics.steps || 0,
                    protein: metrics.protein || 0,
                    supplements: metrics.supplements || false,
                  }
                : {
                    trainingTime: 0,
                    distance: 0,
                    calories: 0,
                    steps: 0,
                    protein: 0,
                    supplements: false,
                  },
              goals: goals
                ? {
                    training_time_goal: goals.training_time_goal || 60,
                    calories_goal: goals.calories_goal || 2000,
                    steps_goal: goals.steps_goal || 10000,
                    protein_goal: goals.protein_goal || 100.0,
                    target_weight: goals.target_weight || null,
                  }
                : {
                    training_time_goal: 60,
                    calories_goal: 2000,
                    steps_goal: 10000,
                    protein_goal: 100.0,
                    target_weight: null,
                  },
            });
          }
        }

        if (loadedPersons.length > 0) {
          console.log("Loaded data from Supabase:", loadedPersons);
          persons.value = loadedPersons;

          // Po załadowaniu danych, załaduj stats dla aktualnie wybranego dnia
          setTimeout(() => {
            console.log(
              "🔄 Loading stats after Supabase data load for:",
              selectedComparisonDate.value
            );
            loadStatsForDate(selectedComparisonDate.value);
          }, 100);
        } else {
          console.log("No data found in Supabase, loading from localStorage");
          loadFromLocalStorage();
        }
      } catch (err) {
        console.error("Error loading from Supabase:", err);
        loadFromLocalStorage();
      }
    };

    const migratePersonNames = (data) => {
      // Migrate old "Osoba 1" and "Osoba 2" to "Fiko" and "Patka"
      const migratedData = [...data];

      if (migratedData.length >= 2) {
        if (migratedData[0].name === "Osoba 1") {
          migratedData[0].name = "Fiko";
        }
        if (migratedData[1].name === "Osoba 2") {
          migratedData[1].name = "Patka";
        }
      }

      console.log("Migrated person names:", migratedData);
      return migratedData;
    };

    const loadFromLocalStorage = () => {
      const saved = localStorage.getItem("fitcompare-data");
      if (saved) {
        const parsedData = JSON.parse(saved);
        const migratedData = migratePersonNames(parsedData);
        persons.value = migratedData;

        // Save migrated data back to localStorage
        localStorage.setItem("fitcompare-data", JSON.stringify(migratedData));
      }
    };

    onMounted(() => {
      // Check if user is already logged in
      const savedUser = localStorage.getItem("fitcompare-user");
      if (savedUser) {
        currentUser.value = JSON.parse(savedUser);
        isLoggedIn.value = true;
        loadDataFromSupabase();
      }

      // Ustaw dzisiejszą datę jako domyślną dla porównania
      const todayString = getTodayString();
      selectedComparisonDate.value = todayString;
      selectedDate.value = todayString;
    });

    return {
      activeTab,
      persons,
      dailyStats,
      isLoggedIn,
      currentUser,
      selectedDate,
      today,
      formatSelectedDate,
      daysUntilChallengeEnd,
      currentMonth,
      currentYear,
      selectedComparisonDate,
      weekDays,
      currentWeekRange,
      fikoWeightLoss,
      patkaWeightLoss,
      fikoWeeklyAverages,
      patkaWeeklyAverages,
      formatComparisonDate,
      currentWeekDays,
      updatePerson,
      addTraining,
      removeTraining,
      removeTrainingFromSupabase,
      increment,
      decrement,
      handleLoginSuccess,
      logout,
      getCurrentUserPersonIndex,
      getCurrentUserAvatar,
      setToday,
      setYesterday,
      loadDailyStatsForDate,
      selectComparisonDate,
      goToPreviousWeek,
      goToNextWeek,
      checkIfDateHasData,
      migratePersonNames,
      handleDailyStatsSaved,
      handleGoalsSaved,
      handleTrainingAddedSuccess,
      handleDailyDataTabClick,
      loadStatsForDate,
    };
  },
};
</script>

<style>
/* Global styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
  color: white;
  min-height: 100vh;
}

/* Header styles */
.header {
  background: linear-gradient(145deg, #2c2c2c, #1a1a1a);
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  border-bottom: 3px solid #00c073;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  font-size: 28px;
  font-weight: bold;
  color: #00c073;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.user-details {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  background: linear-gradient(145deg, #00c073, #00a060);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  font-weight: bold;
  box-shadow: 0 4px 8px rgba(255, 127, 39, 0.3);
}

.user-name {
  font-size: 16px;
  font-weight: 500;
  color: #fff;
}

.challenge-counter {
  font-size: 12px;
  color: #ff4444;
  font-weight: 600;
  background: rgba(255, 68, 68, 0.15);
  padding: 2px 8px;
  border-radius: 12px;
  border: 1px solid rgba(255, 68, 68, 0.4);
}

.logout-btn {
  background: linear-gradient(145deg, #ff4444, #cc3333);
  border: none;
  border-radius: 8px;
  color: white;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 8px rgba(255, 68, 68, 0.3);
}

.logout-btn:hover {
  background: linear-gradient(145deg, #cc3333, #aa2222);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(255, 68, 68, 0.4);
}

/* Navigation styles */
.nav {
  background-color: #333;
  padding: 0;
  border-bottom: 2px solid #444;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
}

.nav-tab {
  background: none;
  border: none;
  color: #ccc;
  padding: 15px 25px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border-bottom: 3px solid transparent;
  position: relative;
}

.nav-tab:hover {
  color: white;
  background-color: #444;
}

.nav-tab.active {
  color: #00c073;
  border-bottom-color: #00c073;
  background-color: #2a2a2a;
}

.nav-tab.active::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #00c073, #00a060);
}

/* Main content */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
}

/* Comparison view */
.comparison-container {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.calendar-section {
  background-color: #2c2c2c;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.calendar-title {
  color: #00c073;
  font-size: 18px;
  font-weight: bold;
}

.calendar-nav {
  display: flex;
  gap: 10px;
}

.calendar-week {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.calendar-day {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  background-color: #333;
  color: #ccc;
}

.calendar-day:hover {
  background-color: #444;
  transform: translateY(-2px);
}

.calendar-day.today {
  background: linear-gradient(145deg, #4caf50, #45a049);
  color: white;
  font-weight: bold;
}

.calendar-day.selected {
  background: linear-gradient(145deg, #00c073, #00a060);
  color: white;
  font-weight: bold;
  box-shadow: 0 4px 8px rgba(255, 127, 39, 0.4);
}

.calendar-day.has-data-fiko {
  background-color: #2e7d32;
  color: white;
}

.calendar-day.has-data-patka {
  background-color: #1976d2;
  color: white;
}

.calendar-day.has-data-both {
  background: linear-gradient(45deg, #2e7d32, #1976d2);
  color: white;
}

.calendar-day.has-data-fiko::after {
  content: "F";
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #4caf50;
  color: white;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.calendar-day.has-data-patka::after {
  content: "P";
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #2196f3;
  color: white;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.calendar-day.has-data-both::after {
  content: "B";
  position: absolute;
  top: -5px;
  right: -5px;
  background-color: #00c073;
  color: white;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

/* Add data view */
.add-data-container {
  background-color: #2c2c2c;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
}

.add-data-title {
  color: white;
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
  text-align: center;
}

.user-info-card {
  background-color: #333;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 25px;
  display: flex;
  align-items: center;
  gap: 15px;
  border: 2px solid #444;
}

.user-avatar {
  width: 60px;
  height: 60px;
  background: linear-gradient(145deg, #00c073, #00a060);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  box-shadow: 0 6px 12px rgba(255, 127, 39, 0.4);
  overflow: hidden;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.avatar-text {
  font-size: 24px;
  line-height: 1;
}

.user-info-details h3 {
  color: white;
  font-size: 20px;
  margin-bottom: 5px;
}

.user-info-details p {
  color: #ccc;
  font-size: 14px;
}

.date-selector {
  background-color: #333;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 25px;
  border: 2px solid #444;
}

.section-title {
  color: #00c073;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 15px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.date-input-group {
  display: flex;
  gap: 15px;
  align-items: center;
  margin-bottom: 15px;
}

.date-input {
  padding: 12px;
  background: linear-gradient(145deg, #1a1a1a, #2a2a2a);
  border: 2px solid #333;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  flex: 1;
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
}

.date-input:focus {
  outline: none;
  border-color: #00c073;
  background: linear-gradient(145deg, #2a2a2a, #1a1a1a);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3),
    0 0 0 3px rgba(255, 127, 39, 0.2);
  transform: translateY(-1px);
}

.date-input:hover {
  border-color: #555;
  transform: translateY(-1px);
}

.date-actions {
  display: flex;
  gap: 10px;
}

.date-btn {
  background: linear-gradient(145deg, #00c073, #00a060);
  border: none;
  border-radius: 8px;
  color: white;
  padding: 10px 16px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 8px rgba(255, 127, 39, 0.3);
}

.date-btn:hover {
  background: linear-gradient(145deg, #00a060, #008050);
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(255, 127, 39, 0.4);
}

.date-info {
  color: #ccc;
  font-size: 14px;
  text-align: center;
}

.date-display {
  text-align: center;
  padding: 15px;
  background: rgba(255, 127, 39, 0.1);
  border-radius: 8px;
  border: 1px solid rgba(255, 127, 39, 0.3);
}

.date-note {
  color: #888;
  font-size: 12px;
  margin-top: 8px;
  font-style: italic;
}

.date-info strong {
  color: #00c073;
}

/* Login form */
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
}

.login-form {
  background-color: #2c2c2c;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
  border: 2px solid #444;
  max-width: 400px;
  width: 100%;
}

.login-title {
  color: white;
  font-size: 28px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 30px;
}

.login-subtitle {
  color: #ccc;
  font-size: 16px;
  text-align: center;
  margin-bottom: 30px;
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

.form-input {
  width: 100%;
  padding: 14px 16px;
  background: linear-gradient(145deg, #1a1a1a, #2a2a2a);
  border: 2px solid #333;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
}

.form-input:focus {
  outline: none;
  border-color: #00c073;
  background: linear-gradient(145deg, #2a2a2a, #1a1a1a);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3),
    0 0 0 3px rgba(255, 127, 39, 0.2);
  transform: translateY(-1px);
}

.form-input:hover {
  border-color: #555;
  transform: translateY(-1px);
}

.login-btn {
  width: 100%;
  padding: 16px 20px;
  background: linear-gradient(145deg, #00c073, #00a060);
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 6px 16px rgba(255, 127, 39, 0.4);
}

.login-btn:hover {
  background: linear-gradient(145deg, #00a060, #008050);
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(255, 127, 39, 0.5);
}

.login-btn:active {
  transform: translateY(0);
  box-shadow: 0 4px 12px rgba(255, 127, 39, 0.4);
}

.login-btn:disabled {
  background: #666;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.error-message {
  background-color: #ff4444;
  color: white;
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 20px;
  text-align: center;
  font-size: 14px;
}

/* Responsive design */
@media (max-width: 768px) {
  .comparison-container {
    flex-direction: column;
  }

  .calendar-week {
    flex-wrap: wrap;
  }

  .calendar-day {
    width: 35px;
    height: 35px;
    font-size: 12px;
  }

  .date-input-group {
    flex-direction: column;
    align-items: stretch;
  }

  .date-actions {
    justify-content: center;
  }

  .user-info {
    flex-direction: column;
    align-items: flex-end;
    gap: 8px;
  }

  .user-details {
    align-items: center;
  }

  .challenge-counter {
    font-size: 11px;
    padding: 1px 6px;
  }
}
</style>
