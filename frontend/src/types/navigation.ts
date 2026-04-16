export interface DashNavItem {
  id: string;
  label: string;
  icon?: string;
  route?: string;
  children?: DashNavItem[];
  badge?: string | number;
  roles?: string[];
  hidden?: boolean;
  dividerBefore?: boolean;
}

export interface DashboardWidgetConfig {
  id: string;
  type: 'stat' | 'chart' | 'table' | 'alert' | 'actions';
  title: string;
  size?: 'sm' | 'md' | 'lg';
  permissions?: string[];
  dataSource?: string;
}

export interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;
}

export interface ConfirmDialogOptions {
  open: boolean;
  title: string;
  message: string;
  onConfirm: () => void;
  onCancel?: () => void;
}

export interface BreadcrumbItem {
  label: string;
  route?: string;
}
