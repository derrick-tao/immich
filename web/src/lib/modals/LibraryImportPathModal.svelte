<script lang="ts">
  import { Button, HStack, Modal, ModalBody, ModalFooter } from '@immich/ui';
  import { mdiFolderSync } from '@mdi/js';
  import { onMount } from 'svelte';
  import { t } from 'svelte-i18n';

  interface Props {
    importPath: string | null;
    importPaths?: string[];
    title?: string;
    cancelText?: string;
    submitText?: string;
    isEditing?: boolean;
    onClose: (data?: { action: 'delete' } | { action: 'submit'; importPath: string | null }) => void;
  }

  let {
    importPath = $bindable(),
    importPaths = $bindable([]),
    title = $t('import_path'),
    cancelText = $t('cancel'),
    submitText = $t('save'),
    isEditing = false,
    onClose,
  }: Props = $props();

  onMount(() => {
    if (isEditing) {
      importPaths = importPaths.filter((path) => path !== importPath);
    }
  });

  let isDuplicate = $derived(importPath !== null && importPaths.includes(importPath));
  let canSubmit = $derived(importPath !== '' && importPath !== null && !importPaths.includes(importPath));

  const onsubmit = (event: Event) => {
    event.preventDefault();
    if (canSubmit) {
      onClose({ action: 'submit', importPath });
    }
  };
</script>

<Modal {title} icon={mdiFolderSync} {onClose} size="small">
  <ModalBody>
    <form {onsubmit} autocomplete="off" id="library-import-path-form">
      <p class="py-5 text-sm">{$t('admin.library_import_path_description')}</p>

      <div class="my-4 flex flex-col gap-2">
        <label class="immich-form-label" for="path">{$t('path')}</label>
        <input class="immich-form-input" id="path" name="path" type="text" bind:value={importPath} />
      </div>

      <div class="mt-8 flex w-full gap-4">
        {#if isDuplicate}
          <p class="text-red-500 text-sm">{$t('errors.import_path_already_exists')}</p>
        {/if}
      </div>
    </form>
  </ModalBody>

  <ModalFooter>
    <HStack fullWidth>
      <Button shape="round" color="secondary" fullWidth onclick={() => onClose()}>{cancelText}</Button>
      {#if isEditing}
        <Button shape="round" color="danger" fullWidth onclick={() => onClose({ action: 'delete' })}>
          {$t('delete')}
        </Button>
      {/if}
      <Button shape="round" type="submit" disabled={!canSubmit} fullWidth form="library-import-path-form">
        {submitText}
      </Button>
    </HStack>
  </ModalFooter>
</Modal>
