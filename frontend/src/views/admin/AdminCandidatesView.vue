<template>
  <div class="admin-candidates">
    <div class="header">
      <div>
        <h1>{{ t('adminCandidates.title') }}</h1>
        <p v-if="election" class="election-name">{{ election.title }}</p>
      </div>
      <BaseButton @click="showAddForm = true">➕ {{ t('adminCandidates.addCandidate') }}</BaseButton>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading">{{ t('adminCandidates.loading') }}</div>

    <!-- Error -->
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadData">{{ t('common.retry') }}</BaseButton>
    </div>

    <!-- Empty -->
    <BaseEmptyState
      v-else-if="candidates.length === 0"
      :title="t('adminCandidates.emptyTitle')"
      :message="t('adminCandidates.emptyMessage')"
      icon="👤"
    />

    <!-- Candidates Table -->
    <div v-else class="candidates-table">
      <table>
        <thead>
          <tr>
            <th>{{ t('common.name') }}</th>
            <th>{{ t('common.class') }}</th>
            <th>{{ t('common.description') }}</th>
            <th>{{ t('common.actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="candidate in candidates" :key="candidate.id">
            <td class="name-cell">{{ candidate.firstName }} {{ candidate.lastName }}</td>
            <td>{{ candidate.className || t('common.notAvailable') }}</td>
            <td>{{ candidate.description || t('common.notAvailable') }}</td>
            <td class="actions-cell">
              <BaseButton size="sm" variant="ghost" @click="startEdit(candidate)">✏️</BaseButton>
              <BaseButton size="sm" variant="ghost" @click="confirmDelete(candidate)">🗑️</BaseButton>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add / Edit Dialog -->
    <BaseDialog
      :open="showAddForm"
      :title="editingCandidate ? t('adminCandidates.editTitle') : t('adminCandidates.addTitle')"
      @update:open="closeForm"
    >
      <form class="candidate-form" @submit.prevent="handleSave">
        <div class="form-row">
          <div class="form-group">
            <label>{{ t('common.firstName') }} *</label>
            <input v-model="candidateForm.firstName" type="text" required />
          </div>
          <div class="form-group">
            <label>{{ t('common.lastName') }} *</label>
            <input v-model="candidateForm.lastName" type="text" required />
          </div>
        </div>
        <div class="form-group">
          <label>{{ t('common.class') }}</label>
          <input v-model="candidateForm.className" type="text" :placeholder="t('adminCandidates.classPlaceholder')" />
        </div>
        <div class="form-group">
          <label>{{ t('common.description') }}</label>
          <textarea v-model="candidateForm.description" rows="3" :placeholder="t('adminCandidates.descriptionPlaceholder')" />
        </div>
      </form>
      <template #footer>
        <BaseButton variant="secondary" @click="closeForm">{{ t('common.cancel') }}</BaseButton>
        <BaseButton :loading="saving" @click="handleSave">{{ t('common.save') }}</BaseButton>
      </template>
    </BaseDialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { candidateApi, electionApi } from '@/api';
import { useLocale } from '@/composables/useLocale';
import { useUiStore } from '@/stores/uiStore';
import type { Candidate, Election } from '@/types';
import BaseButton from '@/components/common/BaseButton.vue';
import BaseDialog from '@/components/common/BaseDialog.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const route = useRoute();
const uiStore = useUiStore();
const electionId = Number(route.params.id);
const { t } = useLocale();

const election = ref<Election | null>(null);
const candidates = ref<Candidate[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const saving = ref(false);
const showAddForm = ref(false);
const editingCandidate = ref<Candidate | null>(null);

const candidateForm = reactive({
  firstName: '',
  lastName: '',
  className: '',
  description: '',
});

function resetForm() {
  candidateForm.firstName = '';
  candidateForm.lastName = '';
  candidateForm.className = '';
  candidateForm.description = '';
  editingCandidate.value = null;
}

function closeForm() {
  showAddForm.value = false;
  resetForm();
}

function startEdit(candidate: Candidate) {
  editingCandidate.value = candidate;
  candidateForm.firstName = candidate.firstName;
  candidateForm.lastName = candidate.lastName;
  candidateForm.className = candidate.className || '';
  candidateForm.description = candidate.description || '';
  showAddForm.value = true;
}

async function handleSave() {
  if (!candidateForm.firstName.trim() || !candidateForm.lastName.trim()) return;
  saving.value = true;

  try {
    if (editingCandidate.value) {
      const updated = await candidateApi.update(editingCandidate.value.id, {
        firstName: candidateForm.firstName,
        lastName: candidateForm.lastName,
        className: candidateForm.className || undefined,
        description: candidateForm.description || undefined,
        electionId,
      });
      const idx = candidates.value.findIndex(c => c.id === updated.id);
      if (idx !== -1) candidates.value[idx] = updated;
      uiStore.showToast({ type: 'success', message: t('adminCandidates.updatedSuccess') });
    } else {
      const created = await candidateApi.create({
        firstName: candidateForm.firstName,
        lastName: candidateForm.lastName,
        className: candidateForm.className || undefined,
        description: candidateForm.description || undefined,
        electionId,
      });
      candidates.value.push(created);
      uiStore.showToast({ type: 'success', message: t('adminCandidates.addedSuccess') });
    }
    closeForm();
  } catch (err: any) {
    uiStore.showToast({ type: 'error', message: err.response?.data?.message || t('adminCandidates.saveFailed') });
  } finally {
    saving.value = false;
  }
}

function confirmDelete(candidate: Candidate) {
  uiStore.openConfirm({
    title: t('adminCandidates.deleteTitle'),
    message: t('adminCandidates.deleteMessage', { name: `${candidate.firstName} ${candidate.lastName}` }),
    onConfirm: async () => {
      try {
        await candidateApi.delete(candidate.id);
        candidates.value = candidates.value.filter(c => c.id !== candidate.id);
        uiStore.showToast({ type: 'success', message: t('adminCandidates.removedSuccess') });
      } catch (err: any) {
        uiStore.showToast({ type: 'error', message: t('adminCandidates.deleteFailed') });
      }
    },
  });
}

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    const [el, cands] = await Promise.all([
      electionApi.getById(electionId),
      candidateApi.getByElection(electionId),
    ]);
    election.value = el;
    candidates.value = cands;
  } catch (err: any) {
    error.value = err.response?.data?.message || t('adminCandidates.loadFailed');
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t('nav.dashboard'), route: '/admin/dashboard' },
    { label: t('nav.elections'), route: '/admin/elections' },
    { label: t('nav.candidates') },
  ]);
  uiStore.setPageTitle(t('adminCandidates.title'));
  loadData();
});
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
}

.header h1 { margin: 0; color: var(--color-text, #1a202c); }

.election-name {
  margin: 0.25rem 0 0 0;
  color: var(--color-text-muted, #718096);
  font-size: 0.9rem;
}

.loading, .error-state {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-muted);
}
.error-state { color: var(--color-danger); }
.error-state p { margin-bottom: 1rem; }

.candidates-table {
  background: var(--color-surface);
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  overflow: hidden;
}

table { width: 100%; border-collapse: collapse; }
th, td { padding: 0.875rem 1rem; text-align: left; border-bottom: 1px solid var(--color-border); font-size: 0.9rem; }
th { background: #f8fafc; font-weight: 600; color: var(--color-text-muted); font-size: 0.8rem; text-transform: uppercase; }
.name-cell { font-weight: 500; }
.actions-cell { display: flex; gap: 0.25rem; }

.candidate-form { display: flex; flex-direction: column; gap: 1rem; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 0.4rem; }
.form-group label { font-weight: 500; font-size: 0.9rem; color: #555; }
.form-group input, .form-group textarea {
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border);
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  width: 100%;
}
.form-group input:focus, .form-group textarea:focus { outline: none; border-color: var(--color-primary); }
</style>
