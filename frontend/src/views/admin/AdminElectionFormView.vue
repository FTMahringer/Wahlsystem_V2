<template>
  <div class="election-form-view">
    <h1>{{ isEdit ? 'Edit Election' : 'Create Election' }}</h1>

    <div v-if="loadingElection" class="loading">Loading...</div>

    <form v-else class="election-form" @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="title">Title *</label>
        <input
          id="title"
          v-model="form.title"
          type="text"
          required
          placeholder="Election title"
          :disabled="submitting"
        />
        <span v-if="errors.title" class="field-error">{{ errors.title }}</span>
      </div>

      <div class="form-group">
        <label for="description">Description</label>
        <textarea
          id="description"
          v-model="form.description"
          rows="4"
          placeholder="Describe the election..."
          :disabled="submitting"
        />
      </div>

      <div class="form-group">
        <label for="type">Election Type *</label>
        <select id="type" v-model="form.type" :disabled="submitting">
          <option value="SINGLE_CHOICE">Single Choice</option>
          <option value="MULTIPLE_CHOICE">Multiple Choice</option>
        </select>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="startAt">Start Date</label>
          <input
            id="startAt"
            v-model="form.startAt"
            type="datetime-local"
            :disabled="submitting"
          />
        </div>
        <div class="form-group">
          <label for="endAt">End Date</label>
          <input
            id="endAt"
            v-model="form.endAt"
            type="datetime-local"
            :disabled="submitting"
          />
          <span v-if="errors.endAt" class="field-error">{{ errors.endAt }}</span>
        </div>
      </div>

      <div class="form-actions">
        <BaseButton variant="secondary" @click="router.push('/admin/elections')">Cancel</BaseButton>
        <BaseButton type="submit" :loading="submitting">
          {{ isEdit ? 'Update Election' : 'Create Election' }}
        </BaseButton>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useElectionStore } from '@/stores/electionStore';
import { useUiStore } from '@/stores/uiStore';
import type { ElectionType } from '@/types';
import BaseButton from '@/components/common/BaseButton.vue';

const route = useRoute();
const router = useRouter();
const electionStore = useElectionStore();
const uiStore = useUiStore();

const isEdit = computed(() => !!route.params.id);
const loadingElection = ref(false);
const submitting = ref(false);

const form = reactive({
  title: '',
  description: '',
  type: 'SINGLE_CHOICE' as ElectionType,
  startAt: '',
  endAt: '',
});

const errors = reactive<Record<string, string>>({});

function validate(): boolean {
  const e: Record<string, string> = {};
  if (!form.title.trim()) e.title = 'Title is required.';
  if (form.startAt && form.endAt && new Date(form.endAt) <= new Date(form.startAt)) {
    e.endAt = 'End date must be after start date.';
  }
  Object.assign(errors, e);
  // Clear old errors
  for (const key of Object.keys(errors)) {
    if (!(key in e)) delete errors[key];
  }
  return Object.keys(e).length === 0;
}

async function handleSubmit() {
  if (!validate()) return;
  submitting.value = true;

  const data = {
    title: form.title.trim(),
    description: form.description.trim(),
    type: form.type,
    startAt: form.startAt ? new Date(form.startAt).toISOString() : null,
    endAt: form.endAt ? new Date(form.endAt).toISOString() : null,
  };

  let result;
  if (isEdit.value) {
    result = await electionStore.update(Number(route.params.id), data);
  } else {
    result = await electionStore.create(data);
  }

  submitting.value = false;

  if (result) {
    uiStore.showToast({ type: 'success', message: isEdit.value ? 'Election updated.' : 'Election created.' });
    router.push('/admin/elections');
  } else {
    uiStore.showToast({ type: 'error', message: electionStore.error || 'Failed to save election.' });
  }
}

onMounted(async () => {
  uiStore.setBreadcrumbs([
    { label: 'Dashboard', route: '/admin/dashboard' },
    { label: 'Elections', route: '/admin/elections' },
    { label: isEdit.value ? 'Edit' : 'Create' },
  ]);
  uiStore.setPageTitle(isEdit.value ? 'Edit Election' : 'Create Election');

  if (isEdit.value) {
    loadingElection.value = true;
    const election = await electionStore.fetchById(Number(route.params.id));
    if (election) {
      form.title = election.title;
      form.description = election.description;
      form.type = election.type;
      form.startAt = election.startAt ? election.startAt.slice(0, 16) : '';
      form.endAt = election.endAt ? election.endAt.slice(0, 16) : '';
    }
    loadingElection.value = false;
  }
});
</script>

<style scoped>
.election-form-view {
  max-width: 700px;
}

.election-form-view h1 {
  margin-bottom: 1.5rem;
  color: var(--color-text, #1a202c);
}

.election-form {
  background: var(--color-surface, #ffffff);
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-group label {
  font-weight: 500;
  font-size: 0.9rem;
  color: #555;
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  transition: border-color 0.2s;
  width: 100%;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary, #667eea);
}

.field-error {
  color: var(--color-danger, #e53e3e);
  font-size: 0.8rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding-top: 0.5rem;
}

.loading {
  padding: 2rem;
  text-align: center;
  color: var(--color-text-muted, #718096);
}
</style>
