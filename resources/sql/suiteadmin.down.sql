-- Teardown for the Suite admin module (tools/module.php purge suiteadmin).
-- The panel owns NO database tables (it only reads the external engines' HTTP
-- health/metrics endpoints and POSTs seeds to onioncrawler), so this only
-- removes the admin page and sweeps any now-orphaned navbar rows. Reinstall via
-- the module SQL in the integration README to restore. No engine state and no
-- other admin page is touched.

DELETE FROM `page` WHERE `module` = 'suiteadmin';   -- cascades to meta/robots/closure/navbar_internal

-- A nav entry whose page is gone is dangling: delete its id-allocator row,
-- which cascades to the entry (navbar_entry.id references navbar_entry_ids).
-- Allocator rows with no entry at all are removed too.
DELETE nid FROM `navbar_entry_ids` nid
  JOIN `navbar_entry` ne ON ne.id = nid.id
  LEFT JOIN `navbar_internal` ni ON ni.id = ne.id
  LEFT JOIN `navbar_external` nx ON nx.id = ne.id
 WHERE ni.id IS NULL AND nx.id IS NULL;
DELETE nid FROM `navbar_entry_ids` nid
  LEFT JOIN `navbar_entry` ne ON ne.id = nid.id
 WHERE ne.id IS NULL;
