export interface AuditLog {
  id: number;
  timestamp: string;
  action: string;
  actorId: number | null;
  actorUsername: string | null;
  actorRole: string | null;
  resourceType: string | null;
  resourceId: number | null;
  details: string | null;
  ipAddress: string | null;
  success: boolean | null;
  errorMessage: string | null;
  endpoint: string | null;
  httpMethod: string | null;
}
