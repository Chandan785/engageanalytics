import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { Bot, MessageCircle, Send } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import kbContent from "../../docs/CHATBOT_KB.md?raw";

interface ChatMessage {
  id: string;
  role: "assistant" | "user";
  content: string;
}

interface Intent {
  id: string;
  keywords: string[];
  response: string;
}

interface KBSection {
  title: string;
  content: string[];
}

const formatResponse = (text: string) =>
  text
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);

const parseKBSections = (text: string): KBSection[] => {
  const lines = text.split("\n");
  const sections: KBSection[] = [];
  let current: KBSection | null = null;

  lines.forEach((line) => {
    const headerMatch = line.match(/^(##|###)\s+(.+)$/);
    if (headerMatch) {
      if (current) sections.push(current);
      current = { title: headerMatch[2].trim(), content: [] };
      return;
    }

    if (!current) return;
    if (line.trim() === "---") return;
    current.content.push(line);
  });

  if (current) sections.push(current);

  return sections.filter((section) => section.content.some((line) => line.trim()));
};

const normalizeText = (text: string) =>
  text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();

const getQueryTokens = (text: string) =>
  normalizeText(text)
    .split(" ")
    .filter((token) => token.length > 2);

export const ChatbotWidget = () => {
  const [open, setOpen] = useState(false);
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: "welcome",
      role: "assistant",
      content:
        "Hi! I’m your ENGAGE Analytics assistant. Ask me how to use any feature (sessions, analytics, admin, consent, exports).",
    },
  ]);

  const scrollRef = useRef<HTMLDivElement | null>(null);
  const kbSections = useMemo(() => parseKBSections(kbContent), []);

  const intents: Intent[] = useMemo(
    () => [
      {
        id: "overview",
        keywords: ["overview", "what is", "about", "project", "engage"],
        response:
          "ENGAGE Analytics is a real-time engagement tracking platform for virtual meetings. It uses on-device AI to measure attention and engagement while keeping video private.",
      },
      {
        id: "all_features",
        keywords: ["all functionalities", "all features", "everything", "use all"],
        response:
          "Core features:\n- Host: create/schedule sessions, live tracking, reports\n- Participant: join via link, consent control\n- Admin: manage users/roles, platform analytics\n- Analytics: trends, comparisons, export\nTell me which area you want step-by-step help with.",
      },
      {
        id: "create_account",
        keywords: [
          "sign up",
          "signup",
          "sign-up",
          "create account",
          "register",
          "new account",
          "create profile",
        ],
        response:
          "First, go to the login page and switch to Sign Up. Fill the form, verify your email, then log in to access the app.",
      },
      {
        id: "login",
        keywords: ["log in", "login", "sign in"],
        response:
          "Use the Auth page to sign in with your email and password.",
      },
      {
        id: "reset_password",
        keywords: ["reset password", "forgot password", "change password"],
        response:
          "Use the Reset Password flow from the Auth page to set a new password.",
      },
      {
        id: "host_create_session",
        keywords: [
          "create session",
          "schedule session",
          "new session",
          "create meeting",
          "schedule meeting",
        ],
        response:
          "Go to Sessions → New Session to create and schedule a meeting. You can launch it anytime after creation.",
      },
      {
        id: "host_launch_session",
        keywords: ["launch session", "start session", "begin session"],
        response:
          "Open your session and click Start/Launch to begin live tracking.",
      },
      {
        id: "join_session",
        keywords: ["join session", "session link", "invite link"],
        response:
          "Use the session link to join. You’ll see a consent prompt before tracking begins.",
      },
      {
        id: "consent",
        keywords: ["consent", "withdraw", "privacy"],
        response:
          "Participants must give consent before tracking starts and can withdraw at any time. Video never leaves the device.",
      },
      {
        id: "live_tracking",
        keywords: ["live tracking", "real-time", "live dashboard"],
        response:
          "Hosts can open Live Tracking from an active session to see engagement in real time.",
      },
      {
        id: "analytics",
        keywords: ["analytics", "reports", "metrics", "trends"],
        response:
          "Open Analytics to view engagement trends, session comparisons, and breakdowns. Filter by session or view all sessions.",
      },
      {
        id: "export",
        keywords: ["export", "download", "report"],
        response:
          "Use the Export option in Analytics to download reports.",
      },
      {
        id: "admin",
        keywords: ["admin", "roles", "permissions", "manage users"],
        response:
          "Admins can manage users, assign roles, view platform analytics, and review audit logs from the Admin Dashboard.",
      },
      {
        id: "super_admin_overview",
        keywords: [
          "super admin",
          "superadmin",
          "super-admin",
          "super admin dashboard",
          "super admin features",
        ],
        response:
          "Super Admins have full system control: advanced role management, SUPER_ADMIN transfer, audit logs, and system settings. Open the Super Admin Dashboard from your profile menu.",
      },
      {
        id: "super_admin_roles",
        keywords: [
          "super admin roles",
          "advanced role management",
          "role management",
          "super admin role",
        ],
        response:
          "Go to Super Admin Dashboard → Role Management (Advanced) to change roles with SUPER_ADMIN rules enforced.",
      },
      {
        id: "super_admin_transfer",
        keywords: [
          "transfer super admin",
          "super admin transfer",
          "change super admin",
          "super admin ownership",
        ],
        response:
          "Open Super Admin Dashboard → Transfer Super Admin. Select a user, choose whether to downgrade yourself, then confirm the transfer.",
      },
      {
        id: "super_admin_audit",
        keywords: ["audit log", "role audit", "system activity", "audit logs"],
        response:
          "Super Admin Dashboard → Audit Logs shows role changes and system activity history.",
      },
      {
        id: "super_admin_settings",
        keywords: ["system settings", "global settings", "feature flags", "policies"],
        response:
          "Super Admin Dashboard → System Settings contains global controls like policies and integrations.",
      },
      {
        id: "support",
        keywords: ["support", "help", "contact"],
        response:
          "You can reach support on the Support page or email support@engageanalytic.me.",
      },
    ],
    []
  );

  const getResponse = (text: string) => {
    const lower = normalizeText(text);
    const match = intents.find((intent) =>
      intent.keywords.some((keyword) => lower.includes(normalizeText(keyword)))
    );

    if (match) return match.response;

    const tokens = getQueryTokens(text);
    if (tokens.length > 0) {
      const sectionMatch = kbSections.find((section) => {
        const title = normalizeText(section.title);
        const content = normalizeText(section.content.join(" "));

        return tokens.some((token) => title.includes(token) || content.includes(token));
      });

      if (sectionMatch) {
        const content = sectionMatch.content
          .map((line) => line.replace(/^[-*]\s+/, ""))
          .filter(Boolean)
          .slice(0, 8)
          .join("\n");

        return `${sectionMatch.title}\n${content}`.trim();
      }
    }

    return (
      "I can help with: sessions, live tracking, analytics, exports, admin roles, consent/privacy, and account access.\nAsk about any of these or say: “how do I host a session?”"
    );
  };

  const handleSend = () => {
    const trimmed = input.trim();
    if (!trimmed) return;

    const userMessage: ChatMessage = {
      id: `${Date.now()}-user`,
      role: "user",
      content: trimmed,
    };

    const assistantMessage: ChatMessage = {
      id: `${Date.now()}-assistant`,
      role: "assistant",
      content: getResponse(trimmed),
    };

    setMessages((prev) => [...prev, userMessage, assistantMessage]);
    setInput("");
  };

  useEffect(() => {
    if (!scrollRef.current) return;
    scrollRef.current.scrollIntoView({ behavior: "smooth" });
  }, [messages, open]);

  return (
    <div className="fixed bottom-6 right-6 z-50">
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetTrigger asChild>
          <Button
            size="icon"
            className="h-12 w-12 rounded-full shadow-lg bg-primary text-primary-foreground"
            aria-label="Open chat assistant"
          >
            <MessageCircle className="h-5 w-5" />
          </Button>
        </SheetTrigger>
        <SheetContent className="w-full sm:max-w-md p-0">
          <div className="flex h-full flex-col">
            <SheetHeader className="px-6 py-4 border-b border-border">
              <SheetTitle className="flex items-center gap-2">
                <Bot className="h-5 w-5" />
                ENGAGE Assistant
              </SheetTitle>
            </SheetHeader>

            <ScrollArea className="flex-1 px-6 py-4">
              <div className="flex flex-col gap-4">
                {messages.map((message) => (
                  <div
                    key={message.id}
                    className={`flex ${
                      message.role === "user" ? "justify-end" : "justify-start"
                    }`}
                  >
                    <div
                      className={`max-w-[85%] rounded-2xl px-4 py-3 text-sm leading-relaxed ${
                        message.role === "user"
                          ? "bg-primary text-primary-foreground"
                          : "bg-muted text-foreground"
                      }`}
                    >
                      {formatResponse(message.content).map((line, idx) => (
                        <p key={`${message.id}-${idx}`} className="mb-2 last:mb-0">
                          {line}
                        </p>
                      ))}
                      {message.role === "assistant" && message.content.includes("Support") && (
                        <div className="mt-2">
                          <Link
                            to="/support"
                            className="text-xs underline text-primary"
                          >
                            Open Support
                          </Link>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
                <div ref={scrollRef} />
              </div>
            </ScrollArea>

            <div className="border-t border-border p-4">
              <div className="flex items-center gap-2">
                <Input
                  value={input}
                  onChange={(event) => setInput(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter") {
                      event.preventDefault();
                      handleSend();
                    }
                  }}
                  placeholder="Ask about sessions, analytics, consent..."
                />
                <Button
                  type="button"
                  size="icon"
                  onClick={handleSend}
                  aria-label="Send message"
                >
                  <Send className="h-4 w-4" />
                </Button>
              </div>
              <div className="mt-2 text-xs text-muted-foreground">
                Try: “How do I host a session?” or “Export analytics”.
              </div>
            </div>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  );
};
