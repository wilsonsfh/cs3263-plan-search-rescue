OUTPUT FORMAT
End your answer with exactly one JSON object in a ```json fenced block:
{
  "steps": [
    {"action": "move", "from": "<place>", "to": "<place>"},
    {"action": "pickup", "location": "<place>"},
    {"action": "dropoff", "location": "<shelter>"}
  ],
  "unreachable": ["<place>"],
  "claimed_total_minutes": <number>
}
- Each "move" drives exactly one road between two directly connected places.
- Use place names exactly as written on the mission sheet.
- "unreachable" lists places with stranded people that cannot be reached (empty list if none).
- "claimed_total_minutes" is the total driving time of your plan.
