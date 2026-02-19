export type TaskPriority = 'P1' | 'P2' | 'P3';
export type TaskStatus = 'active' | 'completed';

export interface Task {
  id: string;
  title: string;
  notes?: string;
  dueDate?: string;
  priority: TaskPriority;
  status: TaskStatus;
  createdAt: string;
  updatedAt: string;
}
