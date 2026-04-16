<template>
  <div class="admin-dashboard">
    <h1>Dashboard</h1>
    
    <div class="welcome-message">
      <h2>Welcome, Admin!</h2>
      <p>You are logged in as <strong>ADMIN</strong></p>
    </div>
    
    <div class="stats-grid">
      <div class="stat-card">
        <h3>Active Elections</h3>
        <p class="stat-value">0</p>
      </div>
      
      <div class="stat-card">
        <h3>Draft Elections</h3>
        <p class="stat-value">0</p>
      </div>
      
      <div class="stat-card">
        <h3>Total Elections</h3>
        <p class="stat-value">0</p>
      </div>
    </div>
    
    <div class="quick-actions">
      <h2>Quick Actions</h2>
      <router-link to="/admin/elections" class="action-button">
        View All Elections
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
// Placeholder dashboard
</script>

<style scoped>
.admin-dashboard h1 {
  margin-bottom: 1rem;
  color: #333;
}

.welcome-message {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.welcome-message h2 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.welcome-message p {
  margin: 0;
  color: #666;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.stat-card h3 {
  margin: 0 0 1rem 0;
  color: #666;
  font-size: 0.9rem;
  text-transform: uppercase;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #667eea;
  margin: 0;
}

.quick-actions {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.quick-actions h2 {
  margin-bottom: 1.5rem;
  color: #333;
}

.action-button {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  background: #667eea;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  margin-right: 1rem;
  margin-bottom: 0.5rem;
}

.action-button:hover {
  background: #5a67d8;
}
</style>
