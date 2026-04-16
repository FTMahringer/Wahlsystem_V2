import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { electionApi } from '@/api';
import type { Election, CreateElectionRequest } from '@/types';

export const useElectionStore = defineStore('election', () => {
  const elections = ref<Election[]>([]);
  const currentElection = ref<Election | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const activeElections = computed(() =>
    elections.value.filter(e => e.status === 'ACTIVE')
  );

  const draftElections = computed(() =>
    elections.value.filter(e => e.status === 'DRAFT')
  );

  const endedElections = computed(() =>
    elections.value.filter(e => e.status === 'ENDED')
  );

  async function fetchAll(): Promise<void> {
    loading.value = true;
    error.value = null;
    try {
      elections.value = await electionApi.getAll();
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load elections.';
    } finally {
      loading.value = false;
    }
  }

  async function fetchById(id: number): Promise<Election | null> {
    loading.value = true;
    error.value = null;
    try {
      const election = await electionApi.getById(id);
      currentElection.value = election;
      return election;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load election.';
      return null;
    } finally {
      loading.value = false;
    }
  }

  async function create(data: CreateElectionRequest): Promise<Election | null> {
    loading.value = true;
    error.value = null;
    try {
      const election = await electionApi.create(data);
      elections.value.push(election);
      return election;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to create election.';
      return null;
    } finally {
      loading.value = false;
    }
  }

  async function update(id: number, data: Partial<CreateElectionRequest>): Promise<Election | null> {
    loading.value = true;
    error.value = null;
    try {
      const election = await electionApi.update(id, data);
      const index = elections.value.findIndex(e => e.id === id);
      if (index !== -1) {
        elections.value[index] = election;
      }
      if (currentElection.value?.id === id) {
        currentElection.value = election;
      }
      return election;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to update election.';
      return null;
    } finally {
      loading.value = false;
    }
  }

  async function deleteElection(id: number): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      await electionApi.delete(id);
      elections.value = elections.value.filter(e => e.id !== id);
      if (currentElection.value?.id === id) {
        currentElection.value = null;
      }
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to delete election.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  function setCurrentElection(election: Election | null) {
    currentElection.value = election;
  }

  return {
    elections,
    currentElection,
    loading,
    error,
    activeElections,
    draftElections,
    endedElections,
    fetchAll,
    fetchById,
    create,
    update,
    deleteElection,
    setCurrentElection,
  };
});
